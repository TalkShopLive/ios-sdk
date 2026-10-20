//
//  VideoViewStateMachine.swift
//
//
//  Created by TalkShopLive on 2026-10-13.
//

import Foundation

// MARK: - VideoViewEvent

/// The two view events the tracker sends.
enum VideoViewEvent: Equatable {
    case view // VIDEO_VIEW
    case engaged // VIDEO_ENGAGED_VIEW

    var action: CollectorRequest.CollectorActionType {
        switch self {
        case .view:
            return .videoView
        case .engaged:
            return .videoEngagedView
        }
    }

    var viewRule: String {
        switch self {
        case .view:
            return "first_frame"
        case .engaged:
            return "engaged_3s"
        }
    }
}

// MARK: - VideoViewEffect

/// Side effects the tracker performs after a state machine transition.
enum VideoViewEffect: Equatable {
    case send(VideoViewEvent, VideoViewSource)
    case scheduleEngagedTimer(afterMs: UInt64, generation: Int)
    case cancelEngagedTimer
}

// MARK: - VideoViewStateMachine

/// Applies the view rule (same as web/embed):
/// - VIDEO_VIEW once per play, at the first rendered frame while the player is playing.
/// - VIDEO_ENGAGED_VIEW once per play, after 3 s of watch time. The clock pauses while paused,
///   buffering or backgrounded. Picture in Picture keeps it running: the video stays on screen.
/// - A new play starts on replay after the end and when the source changes to a different
///   show, phase or stream.
///
/// Pure and synchronous: every input takes the current monotonic time in milliseconds
/// and returns the effects to perform.
struct VideoViewStateMachine {

    static let engagedThresholdMs: UInt64 = 3000

    // MARK: - State

    private(set) var source: VideoViewSource? // Current metadata; nil = no source.
    private var playIdentity: VideoViewSource? // Identity of the current play; kept while source is nil.
    private var isPlaying = false
    private var firstFrameSeen = false
    private var viewSent = false
    private var engagedSent = false
    private var clockStartedAt: UInt64?
    private var accumulatedMs: UInt64 = 0
    private var timerGeneration = 0
    private var timerArmed = false
    private var endedForReplay = false
    private var backgrounded = false
    private var pictureInPicture = false

    // MARK: - Inputs

    mutating func sourceChanged(_ newSource: VideoViewSource?, now: UInt64) -> [VideoViewEffect] {
        guard let newSource = newSource else {
            // No source: pause the clock, keep the play (A -> nil -> A is the same play).
            source = nil
            return pauseClock(now: now)
        }

        var effects: [VideoViewEffect] = []
        if let identity = playIdentity {
            if newSource.isSamePlay(as: identity) {
                // Re-created player, repeated status, live -> transcoding: same play.
                if identity.playbackURL == nil && newSource.playbackURL != nil {
                    playIdentity = newSource
                }
            } else {
                // Different show, phase or stream: new play.
                effects += resetPlay(now: now)
                playIdentity = newSource
            }
        } else {
            playIdentity = newSource
        }
        source = newSource
        return effects + advance(now: now)
    }

    mutating func firstFrame(now: UInt64) -> [VideoViewEffect] {
        firstFrameSeen = true
        return advance(now: now)
    }

    mutating func playbackStateChanged(_ state: VideoViewTracker.PlaybackState, now: UInt64) -> [VideoViewEffect] {
        switch state {
        case .playing:
            isPlaying = true
            if endedForReplay {
                // Replay of the same item: its frame is already on screen,
                // and the player will not report a new first frame.
                endedForReplay = false
                firstFrameSeen = true
            }
            return advance(now: now)
        case .paused, .buffering:
            isPlaying = false
            return pauseClock(now: now)
        }
    }

    mutating func playbackEnded(now: UInt64) -> [VideoViewEffect] {
        let effects = resetPlay(now: now)
        endedForReplay = true
        return effects
    }

    mutating func appBackgrounded(now: UInt64) -> [VideoViewEffect] {
        backgrounded = true
        // Picture in Picture keeps the video on screen: the clock keeps running.
        return pictureInPicture ? [] : pauseClock(now: now)
    }

    mutating func appForegrounded(now: UInt64) -> [VideoViewEffect] {
        backgrounded = false
        return startClock(now: now)
    }

    mutating func pictureInPictureChanged(_ isActive: Bool, now: UInt64) -> [VideoViewEffect] {
        pictureInPicture = isActive
        if isActive {
            return startClock(now: now)
        }
        // PiP closed while the app is in the background: nothing is on screen any more.
        return backgrounded ? pauseClock(now: now) : []
    }

    mutating func engagedTimerFired(generation: Int, now: UInt64) -> [VideoViewEffect] {
        guard generation == timerGeneration, timerArmed, viewSent, !engagedSent else {
            return []
        }
        timerArmed = false
        bank(now: now)
        guard accumulatedMs >= Self.engagedThresholdMs else {
            return startClock(now: now)
        }
        guard let source = source else {
            return []
        }
        engagedSent = true
        accumulatedMs = Self.engagedThresholdMs
        return [.send(.engaged, source)]
    }

    // MARK: - Rule

    /// The video is visible: the app is in the foreground, or Picture in Picture is active.
    private var isOnScreen: Bool {
        !backgrounded || pictureInPicture
    }

    private mutating func advance(now: UInt64) -> [VideoViewEffect] {
        viewSent ? startClock(now: now) : maybeSendView(now: now)
    }

    private mutating func maybeSendView(now: UInt64) -> [VideoViewEffect] {
        guard !viewSent, firstFrameSeen, isPlaying, let source = source else {
            return []
        }
        viewSent = true
        let effects = resetEngaged()
        return effects + [.send(.view, source)] + startClock(now: now)
    }

    private mutating func startClock(now: UInt64) -> [VideoViewEffect] {
        guard viewSent, !engagedSent, isPlaying, isOnScreen, let source = source else {
            return []
        }
        bank(now: now)
        clockStartedAt = now
        timerGeneration += 1
        let remaining = Self.engagedThresholdMs - min(accumulatedMs, Self.engagedThresholdMs)
        guard remaining > 0 else {
            timerArmed = false
            clockStartedAt = nil
            engagedSent = true
            return [.send(.engaged, source)]
        }
        timerArmed = true
        return [.scheduleEngagedTimer(afterMs: remaining, generation: timerGeneration)]
    }

    private mutating func pauseClock(now: UInt64) -> [VideoViewEffect] {
        bank(now: now)
        guard timerArmed else {
            return []
        }
        timerArmed = false
        timerGeneration += 1
        return [.cancelEngagedTimer]
    }

    private mutating func bank(now: UInt64) {
        if let startedAt = clockStartedAt {
            accumulatedMs += now > startedAt ? now - startedAt : 0
            clockStartedAt = nil
        }
    }

    private mutating func resetEngaged() -> [VideoViewEffect] {
        clockStartedAt = nil
        accumulatedMs = 0
        engagedSent = false
        guard timerArmed else {
            return []
        }
        timerArmed = false
        timerGeneration += 1
        return [.cancelEngagedTimer]
    }

    private mutating func resetPlay(now: UInt64) -> [VideoViewEffect] {
        let effects = pauseClock(now: now)
        viewSent = false
        firstFrameSeen = false
        endedForReplay = false
        return effects + resetEngaged()
    }
}
