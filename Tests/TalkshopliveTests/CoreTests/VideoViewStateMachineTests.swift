// VideoViewStateMachineTests.swift
// Offline unit tests for the video view rule (VIDEO_VIEW / VIDEO_ENGAGED_VIEW).
// The state machine is driven with a manual clock, so no test waits for real time.

import XCTest
@testable import Talkshoplive

final class VideoViewStateMachineTests: XCTestCase {

    // MARK: - VIDEO_VIEW

    func test_view_firstFrameWhilePlaying_sentOnce() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)

        XCTAssertEqual(driver.sent.first, .view(at: 0))
        XCTAssertEqual(driver.sent.filter { $0.event == .view }.count, 1)
    }

    func test_view_firstFrameWhilePaused_waitsForPlaying() {
        var driver = Driver()
        driver.source(Self.vodA, at: 0)
        driver.state(.paused, at: 0)
        driver.firstFrame(at: 500)
        driver.state(.playing, at: 2000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 2000), .engaged(at: 5000)])
    }

    func test_view_playingWithoutFirstFrame_notSent() {
        var driver = Driver()
        driver.source(Self.vodA, at: 0)
        driver.state(.playing, at: 0)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [])
    }

    func test_view_noSource_sentWhenSourceArrives() {
        var driver = Driver()
        driver.state(.playing, at: 0)
        driver.firstFrame(at: 0)
        driver.advance(to: 1000)
        XCTAssertEqual(driver.sent, [])

        driver.source(Self.vodA, at: 1000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 1000), .engaged(at: 4000)])
    }

    func test_view_repeatedPlayingAndFirstFrame_noDuplicates() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.state(.playing, at: 500)
        driver.firstFrame(at: 700)
        driver.state(.playing, at: 1000)
        driver.state(.playing, at: 2500)
        driver.state(.playing, at: 4000)
        driver.firstFrame(at: 4500)
        driver.state(.playing, at: 9000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
    }

    // MARK: - VIDEO_ENGAGED_VIEW

    func test_engaged_after3sOfPlaying_sentOnce() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
        XCTAssertNil(driver.pendingTimer)
    }

    func test_engaged_pauseAt2sAndResume_sentWhen3sOfWatchTimeReached() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.state(.paused, at: 2000)
        driver.state(.playing, at: 10_000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 11_000)])
    }

    func test_engaged_buffering_pausesClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.state(.buffering, at: 1000)
        driver.state(.playing, at: 4000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 6000)])
    }

    func test_engaged_background_pausesClock_noNewView() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.background(at: 1000)
        driver.foreground(at: 5000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 7000)])
    }

    func test_engaged_playingReportedWhileInBackground_clockStaysPaused() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.background(at: 1000)
        driver.state(.playing, at: 2000)   // e.g. background audio keeps the player playing
        driver.source(Self.vodA, at: 2500) // status refresh while in the background
        driver.advance(to: 20_000)
        XCTAssertEqual(driver.sent, [.view(at: 0)])

        driver.foreground(at: 20_000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 22_000)])
    }

    func test_engaged_foregroundWhilePaused_doesNotStartClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.background(at: 1000)
        driver.state(.paused, at: 1000)
        driver.foreground(at: 5000)
        driver.advance(to: 20_000)
        XCTAssertEqual(driver.sent, [.view(at: 0)])

        driver.state(.playing, at: 20_000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 22_000)])
    }

    func test_engaged_afterEngagedSent_noMoreEvents() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.advance(to: 4000)
        driver.state(.paused, at: 4000)
        driver.state(.playing, at: 5000)
        driver.background(at: 6000)
        driver.foreground(at: 7000)
        driver.state(.buffering, at: 8000)
        driver.state(.playing, at: 9000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
        XCTAssertNil(driver.pendingTimer)
    }

    func test_engaged_staleTimerAfterPauseAndResume_ignored() {
        var machine = VideoViewStateMachine()
        _ = machine.sourceChanged(Self.vodA, now: 0)
        _ = machine.playbackStateChanged(.playing, now: 0)
        let effects = machine.firstFrame(now: 0)
        guard case .scheduleEngagedTimer(_, let staleGeneration)? = effects.last else {
            return XCTFail("Expected an engaged timer, got \(effects)")
        }
        _ = machine.playbackStateChanged(.paused, now: 1000)
        _ = machine.playbackStateChanged(.playing, now: 2000) // a new timer for the remaining 2000 ms

        XCTAssertEqual(machine.engagedTimerFired(generation: staleGeneration, now: 3000), [])
    }

    func test_engaged_nilSource_pausesClockAndKeepsPlay() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.source(nil, at: 1000)
        driver.source(Self.vodA, at: 5000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 7000)])
    }

    // MARK: - New play / same play

    func test_newPlay_replayAfterEnd_sendsNewViewAndEngaged() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.ended(at: 10_000)
        driver.state(.paused, at: 10_000)
        driver.state(.playing, at: 12_000) // The player reports no new first frame on replay.
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000), .view(at: 12_000), .engaged(at: 15_000)])
    }

    func test_newPlay_replayBeforeEngaged_restartsEngagedClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.ended(at: 2000)
        driver.state(.paused, at: 2000)
        driver.state(.playing, at: 5000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .view(at: 5000), .engaged(at: 8000)])
    }

    func test_newPlay_differentShow_sendsNewViewAndEngaged() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.source(Self.vodB, at: 10_000)
        driver.firstFrame(at: 10_500)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [
            .view(at: 0), .engaged(at: 3000),
            .view(at: 10_500, showId: 2), .engaged(at: 13_500, showId: 2),
        ])
    }

    func test_newPlay_differentShowBeforeEngaged_dropsFirstEngaged() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.source(Self.vodB, at: 2000)
        driver.firstFrame(at: 2200)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .view(at: 2200, showId: 2), .engaged(at: 5200, showId: 2)])
    }

    func test_newPlay_preliveToLiveToVod_sameShow_eachPhaseIsANewPlay() {
        var driver = Driver()
        driver.startPlaying(Self.source(showId: 1, status: .prelive, url: "https://cdn.example.com/trailer.mp4"), at: 0)
        driver.source(Self.source(showId: 1, status: .live, url: "https://cdn.example.com/live/index.m3u8"), at: 10_000)
        driver.firstFrame(at: 10_300)
        driver.source(Self.source(showId: 1, status: .vod, url: "https://cdn.example.com/vod/index.m3u8"), at: 20_000)
        driver.firstFrame(at: 20_200)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent.map(\.at), [0, 3000, 10_300, 13_300, 20_200, 23_200])
        XCTAssertEqual(driver.sent.map(\.videoStatus), [.prelive, .prelive, .live, .live, .vod, .vod])
    }

    func test_samePlay_recreatedPlayerWithNewUrlToken_noNewView() {
        var driver = Driver()
        driver.startPlaying(Self.source(showId: 1, status: .vod, url: "https://cdn.example.com/vod/index.m3u8?token=1"), at: 0)
        driver.source(Self.source(showId: 1, status: .vod, url: "https://CDN.example.com/vod/index.m3u8?token=2"), at: 1500)
        driver.state(.buffering, at: 1500)
        driver.firstFrame(at: 1600)
        driver.state(.playing, at: 1600)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3100)])
    }

    func test_samePlay_repeatedStatusRefresh_noNewView() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        for time: UInt64 in stride(from: 500, through: 20_000, by: 500) {
            driver.source(Self.vodA, at: time)
        }
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
    }

    // MARK: - Picture in Picture

    func test_pip_startedBeforeBackground_clockKeepsRunning() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 1000)
        driver.background(at: 1100)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
    }

    func test_pip_startedAfterBackground_clockResumes() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.background(at: 1000)
        driver.pictureInPicture(true, at: 1500)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3500)])
    }

    func test_pip_pausedInsidePip_pausesClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 500)
        driver.background(at: 1000)
        driver.state(.paused, at: 2000)
        driver.state(.playing, at: 6000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 7000)])
    }

    func test_pip_closedWhileInBackground_pausesClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 1000)
        driver.background(at: 1000)
        driver.pictureInPicture(false, at: 2000)
        driver.foreground(at: 9000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 10_000)])
    }

    func test_pip_inAppWhileForeground_changesNothing() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 1000)
        driver.pictureInPicture(false, at: 2000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
    }

    func test_pip_restoredIntoApp_clockKeepsRunning() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 500)
        driver.background(at: 600)
        driver.foreground(at: 2000)
        driver.pictureInPicture(false, at: 2100)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
    }

    func test_pip_activeThroughReplay_sendsNewViewAndEngaged() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 500)
        driver.background(at: 600)
        driver.ended(at: 10_000)
        driver.state(.paused, at: 10_000)
        driver.state(.playing, at: 11_000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000), .view(at: 11_000), .engaged(at: 14_000)])
    }

    func test_pip_togglesAfterEngaged_sendNothing() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.pictureInPicture(true, at: 4000)
        driver.background(at: 4100)
        driver.pictureInPicture(false, at: 5000)
        driver.foreground(at: 6000)
        driver.pictureInPicture(true, at: 7000)
        driver.advance(to: 60_000)

        XCTAssertEqual(driver.sent, [.view(at: 0), .engaged(at: 3000)])
        XCTAssertNil(driver.pendingTimer)
    }

    func test_pip_withoutHook_backgroundStillPausesClock() {
        var driver = Driver()
        driver.startPlaying(Self.vodA, at: 0)
        driver.background(at: 1000) // PiP after Home, but the host never calls onPictureInPictureChanged.
        driver.advance(to: 20_000)

        XCTAssertEqual(driver.sent, [.view(at: 0)])
    }

    // MARK: - Helpers

    private static let vodA = source(showId: 1, status: .vod, url: "https://cdn.example.com/a/index.m3u8")
    private static let vodB = source(showId: 2, status: .vod, url: "https://cdn.example.com/b/index.m3u8")

    private static func source(showId: Int, status: VideoViewSource.VideoStatus, url: String) -> VideoViewSource {
        VideoViewSource(showId: showId, showKey: "show-\(showId)", videoStatus: status, playbackURL: URL(string: url))
    }
}

// MARK: - Driver

/// Drives `VideoViewStateMachine` the way `VideoViewTracker` does: a manual clock in milliseconds
/// and one pending engaged timer (a new schedule replaces it, a cancel removes it).
private struct Driver {

    struct Sent: Equatable {
        let event: VideoViewEvent
        let at: UInt64
        var showId: Int = 1
        var videoStatus: VideoViewSource.VideoStatus = .vod

        static func view(at time: UInt64, showId: Int = 1) -> Sent {
            Sent(event: .view, at: time, showId: showId)
        }

        static func engaged(at time: UInt64, showId: Int = 1) -> Sent {
            Sent(event: .engaged, at: time, showId: showId)
        }
    }

    private var machine = VideoViewStateMachine()
    private var now: UInt64 = 0
    private(set) var pendingTimer: (fireAt: UInt64, generation: Int)?
    private(set) var sent: [Sent] = []

    // MARK: Inputs

    mutating func source(_ source: VideoViewSource?, at time: UInt64) {
        input(at: time) { $0.sourceChanged(source, now: $1) }
    }

    mutating func firstFrame(at time: UInt64) {
        input(at: time) { $0.firstFrame(now: $1) }
    }

    mutating func state(_ state: VideoViewTracker.PlaybackState, at time: UInt64) {
        input(at: time) { $0.playbackStateChanged(state, now: $1) }
    }

    mutating func ended(at time: UInt64) {
        input(at: time) { $0.playbackEnded(now: $1) }
    }

    mutating func background(at time: UInt64) {
        input(at: time) { $0.appBackgrounded(now: $1) }
    }

    mutating func foreground(at time: UInt64) {
        input(at: time) { $0.appForegrounded(now: $1) }
    }

    mutating func pictureInPicture(_ isActive: Bool, at time: UInt64) {
        input(at: time) { $0.pictureInPictureChanged(isActive, now: $1) }
    }

    /// Source, playing and first frame at the same moment: the usual start of a play.
    mutating func startPlaying(_ source: VideoViewSource, at time: UInt64) {
        self.source(source, at: time)
        state(.playing, at: time)
        firstFrame(at: time)
    }

    /// Moves the clock forward, firing the engaged timer when it is due. Inputs must be in time order.
    mutating func advance(to time: UInt64) {
        precondition(time >= now, "Driver inputs must be in time order")
        while let timer = pendingTimer, timer.fireAt <= time {
            now = timer.fireAt
            pendingTimer = nil
            perform(machine.engagedTimerFired(generation: timer.generation, now: now))
        }
        now = time
    }

    // MARK: Private

    private mutating func input(at time: UInt64, _ transition: (inout VideoViewStateMachine, UInt64) -> [VideoViewEffect]) {
        advance(to: time)
        let current = now
        perform(transition(&machine, current))
    }

    private mutating func perform(_ effects: [VideoViewEffect]) {
        for effect in effects {
            switch effect {
            case .send(let event, let source):
                sent.append(Sent(event: event, at: now, showId: source.showId, videoStatus: source.videoStatus))
            case .scheduleEngagedTimer(let afterMs, let generation):
                pendingTimer = (now + afterMs, generation)
            case .cancelEngagedTimer:
                pendingTimer = nil
            }
        }
    }
}
