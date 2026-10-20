//
//  VideoViewTracker.swift
//
//
//  Created by TalkShopLive on 2026-10-13.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

// MARK: - VideoViewTracker

/// Sends VIDEO_VIEW and VIDEO_ENGAGED_VIEW for the host app's player.
///
/// The host app forwards its player events to the hooks below and the SDK applies the view rule:
/// - VIDEO_VIEW (`view_rule: first_frame`) once per play, at the first rendered frame while playing.
/// - VIDEO_ENGAGED_VIEW (`view_rule: engaged_3s`) once per play, after 3 s of watch time.
///   The clock pauses while paused, buffering or while the app is in the background.
///   Picture in Picture keeps it running (see `onPictureInPictureChanged(_:)`): the video stays on screen.
/// - Pause/resume, seek, buffering, background/foreground, rotation and re-creating the player for
///   the same source never send a new view. Replay after the end, a different show/stream and
///   prelive -> live start a new play.
/// - With DNT on, both events are sent anonymously.
///
/// Create one tracker per player and keep it for as long as the video plays, also in Picture in
/// Picture after the player screen is gone: keep it next to the object that keeps the player alive
/// (rotation and fullscreen use the same tracker). Every method is thread-safe.
public final class VideoViewTracker {

    // MARK: - PlaybackState

    /// The playback state reported by the host app's player.
    public enum PlaybackState {
        case playing
        case paused
        case buffering
    }

    // MARK: - Properties

    private let userId: String
    private let queue = DispatchQueue(label: "live.talkshop.sdk.videoviews")
    private var stateMachine = VideoViewStateMachine()
    private var engagedTimer: DispatchWorkItem?
    private var screenResolution: String = "NOT_SET"
    private var lifecycleObservers: [NSObjectProtocol] = []

    // MARK: - Initializer

    /// Creates a tracker for one player screen.
    /// - Parameter userId: The user id sent as `user_id` (not sent when DNT is on).
    public init(userId: String) {
        self.userId = userId
        captureScreenResolution()
        observeAppLifecycle()
    }

    deinit {
        lifecycleObservers.forEach { NotificationCenter.default.removeObserver($0) }
        engagedTimer?.cancel()
    }

    // MARK: - Player Hooks

    /// Call when the player loads a stream, and again with every show status refresh.
    ///
    /// Calling it again with the same show, phase and stream does nothing. A different show,
    /// phase (e.g. prelive -> live) or stream starts a new play. Call it before the player
    /// starts the new stream. Pass nil when nothing is loaded: the engaged clock pauses and
    /// the current play is kept.
    public func onSourceChanged(_ source: VideoViewSource?) {
        apply { $0.sourceChanged(source, now: $1) }
    }

    /// Call when the player renders its first video frame
    /// (AVPlayer: `AVPlayerLayer.isReadyForDisplay` / `AVPlayerViewController.isReadyForDisplay` becomes true).
    public func onFirstFrame() {
        apply { $0.firstFrame(now: $1) }
    }

    /// Call whenever the player starts playing, pauses or starts buffering
    /// (AVPlayer: `timeControlStatus` `.playing` / `.paused` / `.waitingToPlayAtSpecifiedRate`).
    public func onPlaybackStateChanged(_ state: PlaybackState) {
        apply { $0.playbackStateChanged(state, now: $1) }
    }

    /// Call when playback reaches the end (AVPlayer: `AVPlayerItemDidPlayToEndTime`).
    /// Playing again afterwards is a new play.
    public func onPlaybackEnded() {
        apply { $0.playbackEnded(now: $1) }
    }

    /// Call when Picture in Picture starts or stops (`AVPlayerViewControllerDelegate` / `AVPictureInPictureControllerDelegate`):
    /// `…WillStartPictureInPicture(_:)` -> true; `…DidStopPictureInPicture(_:)` and
    /// `…(_:failedToStartPictureInPictureWithError:)` -> false.
    /// While PiP is active the video stays on screen, so leaving the app does not pause the engaged clock.
    public func onPictureInPictureChanged(_ isActive: Bool) {
        apply { $0.pictureInPictureChanged(isActive, now: $1) }
    }

    // MARK: - App Lifecycle

    func onAppBackgrounded() {
        apply { $0.appBackgrounded(now: $1) }
    }

    func onAppForegrounded() {
        apply { $0.appForegrounded(now: $1) }
    }

    private func observeAppLifecycle() {
#if canImport(UIKit) && !os(watchOS)
        let center = NotificationCenter.default
        lifecycleObservers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.onAppBackgrounded()
        })
        lifecycleObservers.append(center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] _ in
            self?.onAppForegrounded()
        })
#endif
    }

    // MARK: - State Machine

    /// Captures the time on the calling thread, then runs the transition on the tracker queue.
    private func apply(_ transition: @escaping (inout VideoViewStateMachine, UInt64) -> [VideoViewEffect]) {
        let now = Self.nowMs()
        queue.async { [weak self] in
            guard let self = self else { return }
            let effects = transition(&self.stateMachine, now)
            effects.forEach { self.perform($0) }
        }
    }

    private func perform(_ effect: VideoViewEffect) {
        switch effect {
        case .send(let event, let source):
            send(event, source: source)
        case .scheduleEngagedTimer(let afterMs, let generation):
            engagedTimer?.cancel()
            let timer = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                let effects = self.stateMachine.engagedTimerFired(generation: generation, now: Self.nowMs())
                effects.forEach { self.perform($0) }
            }
            engagedTimer = timer
            queue.asyncAfter(deadline: .now() + .milliseconds(Int(afterMs)), execute: timer)
        case .cancelEngagedTimer:
            engagedTimer?.cancel()
            engagedTimer = nil
        }
    }

    /// Monotonic time in milliseconds.
    private static func nowMs() -> UInt64 {
        DispatchTime.now().uptimeNanoseconds / 1_000_000
    }

    // MARK: - Sending

    private func send(_ event: VideoViewEvent, source: VideoViewSource) {
        let anonymous = Config.shared.isDntMode()
        let action = event.action

        Networking.collect(
            userId: userId,
            category: action.associatedCategory,
            version: SDKInfo.version,
            action: action,
            eventId: source.eventId,
            showKey: source.showKey,
            storeId: source.storeId,
            videoStatus: source.videoStatus.rawValue,
            screenResolution: screenResolution,
            showTitle: source.title,
            showId: source.showId,
            viewRule: event.viewRule,
            anonymous: anonymous
        )
    }

    /// Reads the screen size on the main thread (UIKit) for the `aspect` field.
    private func captureScreenResolution() {
        if Thread.isMainThread {
            screenResolution = getScreenResolution()
        } else {
            DispatchQueue.main.async { [weak self] in
                let resolution = getScreenResolution()
                self?.queue.async { self?.screenResolution = resolution }
            }
        }
    }
}
