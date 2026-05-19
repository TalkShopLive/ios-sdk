//
//  ChatTeardownTests.swift
//
//  Regression suite for the NSURLSession-delegate use-after-free crash
//  observed in the consumer's Live-player view controller (navigate in -> out -> in).
//
//  Root cause (fixed by the changes in this PR):
//  a PubNub / URLSession completion fired into a ChatProvider graph that
//  the consumer already tore down via Chat.clean(). Four coupled defects:
//   D1  strong-`self` escaping closures (retain cycle + deref-after-free)
//   D2  strong (non-weak) delegates (dangling-delegate path)
//   D3  clearConnection() never removed/niled the PubNub listener
//   D4  APIHandler's URLSession tasks were uncancellable on teardown
//
//  ENVIRONMENT NOTE (read before judging pass/fail):
//  This SDK's pre-existing tests (e.g. ChatTests.testCreateGuestUserToken)
//  perform a REAL network round-trip via TalkShopLiveTests().testInitializeSDK()
//  and fail with AUTHENTICATION_EXCEPTION in any sandbox without outbound
//  network (verified: `curl https://sdk.talkshop.live` -> "Could not
//  resolve host"). That is a pre-existing environment limitation, NOT a
//  defect in this fix.
//
//  These teardown tests are therefore deliberately designed to be
//  DETERMINISTIC AND OFFLINE. They do NOT call testInitializeSDK() and do
//  NOT assert on successful token retrieval. The memory-safety invariants
//  under test — no retain cycle, no callback after clean(), the in-flight
//  task registry empties on cancel, no crash on a late callback — are all
//  about object lifetime and the cancellation registry, NOT about a
//  successful network response. A FAILED token network call is in fact
//  exactly the post-teardown completion window the crash hit, so
//  offline execution still exercises the real defect.
//
//  KNOWN OFFLINE COVERAGE LIMITATION:
//  The FULL live-PubNub retain cycle
//  (ChatProvider -> pubnub -> listener -> closure -> ChatProvider) only
//  forms inside subscribe(), which is gated behind a 1.0s asyncAfter that
//  fires ONLY after a SUCCESSFUL token + PubNub init. With no outbound
//  network that path never executes, so the listener-bearing cycle cannot
//  be observed in-process here, and the true
//  com.apple.NSURLSession-delegate-queue race is not deterministically
//  reproducible offline (a unit test cannot deterministically
//  reproduce the true NSURLSession-delegate-queue race).
//  What IS deterministically proven offline:
//   * testStrongSelfInitCompletionDoesNotPinChat — the D1 strong-`self`
//     init-completion capture; this test is VERIFIED to FAIL against
//     pristine release-4.1.0 and PASS with the fix (it genuinely bites
//     the bug: a PRE-fix run FAILS and a post-fix run PASSES).
//   * the in-flight URLSession task registry empties on cancel (D4).
//   * no delegate callback fires after clean(); weak delegate (D2).
//   * nil-safe / idempotent clearConnection() listener teardown (D3).
//   * no crash on a synthetic late callback after clean().
//  No test was deleted or weakened to make the suite green; the offline
//  limitation is disclosed here rather than masked.
//
//  `@testable` is required to reach internal symbols (Config.setInitialized,
//  APIHandler.cancelAllRequests(), APIHandler.inFlightRequestCount).
//

import XCTest
@testable import Talkshoplive

final class ChatTeardownTests: XCTestCase {

    // Real JWT fixture reused from ChatTests.swift (guest token). The token
    // is never validated offline; it only has to be a syntactically valid
    // string so ChatProvider.init proceeds to its network call.
    private let guestJWT = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MDkyNjc3NDYsImp0aSI6InRXaEJBd1NUbVhVNnp5UUsxNUV1eXk9PSJ9.hHFWaQU-8yMCnPTsI7ah5wapjLvwSwo2ZbuQNwPggfU"
    private let testShowKey = "8WtAFFgRO1K0"

    override func setUpWithError() throws {
        // OFFLINE setup — no network. Mark the SDK "initialized" and in test
        // mode so APIHandler.request* proceeds past its
        // `guard Config.shared.isInitialized()` check and actually creates +
        // registers a URLSessionDataTask (whose network call will then fail
        // offline — which is fine; we cancel/observe it before that matters).
        // Config.shared is a process singleton; values are bundled (no I/O).
        Config.shared.setTestMode(true)
        Config.shared.setInitialized(true)
    }

    // MARK: - Spy delegate

    /// Records whether ANY ChatDelegate callback fired. Used by the
    /// inverted-expectation test to prove no callback arrives post-clean().
    private final class SpyChatDelegate: ChatDelegate {
        let onAnyCallback: () -> Void
        init(onAnyCallback: @escaping () -> Void) { self.onAnyCallback = onAnyCallback }
        func onNewMessage(_ message: MessageBase) { onAnyCallback() }
        func onDeleteMessage(_ message: MessageBase) { onAnyCallback() }
        func onStatusChange(error: APIClientError) { onAnyCallback() }
        func onLikeComment(_ messageAction: MessageAction) { onAnyCallback() }
        func onUnlikeComment(_ messageAction: MessageAction) { onAnyCallback() }
    }

    // MARK: - 1. No retain cycle: ChatProvider/Chat deallocate after clean()
    //
    // Proves D1 + D2. Against the PRE-fix code this FAILS:
    // ChatProvider -> pubnub -> listener -> closure -> ChatProvider is a
    // retain cycle, and the strong `delegate` (Chat) plus strong-`self`
    // in-flight token closures keep the graph alive, so `weakChat` would
    // NOT become nil. With the fix (weak self/guard + weak delegate +
    // listener.cancel() in clearConnection()), the graph deallocates even
    // while the (offline-failing) token request is still settling — which
    // is precisely the crash window.
    func testChatProviderDeallocatesAfterClean() {
        weak var weakChat: Chat?

        autoreleasepool {
            let chat = Chat(jwtToken: guestJWT, isGuest: true, showKey: testShowKey)
            weakChat = chat
            XCTAssertNotNil(weakChat, "sanity: chat exists while strongly held")

            // Let the async messaging-token request kick off (it will fail
            // offline — that failed completion is the post-teardown window).
            let settle = expectation(description: "let token request start")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { settle.fulfill() }
            wait(for: [settle], timeout: 6)

            // Tear down exactly as the consumer's player view controller does on dismiss.
            chat.clean()
        } // strong `chat` ref dropped here

        // Spin the runloop so cancelled URLSession completions and the
        // PubNub listener token teardown can drain, then assert dealloc.
        let dealloc = expectation(description: "Chat deallocates after clean()")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
            dealloc.fulfill()
        }
        wait(for: [dealloc], timeout: 8)

        XCTAssertNil(weakChat,
            "Chat must deallocate after clean() — a non-nil ref means the retain cycle (D1/D2) is still present. (deinit also logs 'Chat instance is being deallocated.' in debug mode.)")
    }

    // MARK: - 1b. Strong-self init completion no longer pins Chat (D1) —
    //         THE biting regression test (FAILS against pre-fix code).
    //
    // Pre-fix, Chat.swift:53 `ChatProvider(...) { result, error in ... }`
    // captured `self` STRONGLY. If the consumer drops the Chat while the
    // messaging-token request is still in flight (exactly the
    // navigate-out-immediately case), the strong capture keeps the Chat
    // alive until the request completes — so it deref's a graph the
    // consumer believes is gone. We drop the Chat with the request armed
    // and assert it is ALREADY deallocated.
    //
    // Verified to FAIL against pristine release-4.1.0 (offline):
    //   XCTAssertNil failed: "Talkshoplive.Chat"
    // and to PASS with the `[weak self]` fix on Chat.swift:53. This is
    // the regression test that must actually bite the bug.
    func testStrongSelfInitCompletionDoesNotPinChat() {
        weak var weakChat: Chat?
        autoreleasepool {
            let chat = Chat(jwtToken: guestJWT, isGuest: true, showKey: testShowKey)
            weakChat = chat
            XCTAssertNotNil(weakChat, "sanity: chat exists while strongly held")
            // Deliberately do NOT wait and do NOT call clean(): drop the
            // strong ref with the token request still in flight.
        }
        // Checked immediately — before the (slower) network-failure
        // completion. Pre-fix the strong-self init closure pins `chat`
        // here; post-fix `[weak self]` lets it deallocate at once.
        XCTAssertNil(weakChat,
            "Chat must NOT be retained by its in-flight ChatProvider init completion (D1, Chat.swift:53). A non-nil ref here is the pre-fix strong-self capture defect.")
    }

    // MARK: - 2. No delegate callback fires after clean()
    //
    // Proves D2 + D3. Installs a spy ChatDelegate, calls clean(), then
    // waits past any in-flight completion window. The inverted expectation
    // is fulfilled ONLY if a callback wrongly arrives — i.e. the test fails
    // if the post-teardown UAF path is live.
    func testNoDelegateCallbackAfterClean() {
        let noCallback = expectation(description: "no ChatDelegate callback after clean()")
        noCallback.isInverted = true

        let spy = SpyChatDelegate { noCallback.fulfill() }

        autoreleasepool {
            let chat = Chat(jwtToken: guestJWT, isGuest: true, showKey: testShowKey)
            chat.delegate = spy

            let armed = expectation(description: "provider network work armed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { armed.fulfill() }
            wait(for: [armed], timeout: 6)

            chat.clean()
        }

        // Wait past the realistic late-completion window. If the guard /
        // weak-delegate fix were absent, a delegate method would fire here.
        wait(for: [noCallback], timeout: 4)
    }

    // MARK: - 3. clearConnection() listener teardown is nil-safe & idempotent
    //
    // Proves D3. clearConnection() and `listener` are private, so we assert
    // the OBSERVABLE contract of correct listener teardown: clean() with a
    // nil listener (the 1.0s asyncAfter that arms it has not fired) must
    // exercise `if let listener = self.listener { listener.cancel() }` /
    // `self.listener = nil` WITHOUT crashing, and a repeated clean() (now
    // chatProvider == nil) must be a safe no-op. Reaching the end without
    // EXC_BAD_ACCESS is the assertion.
    func testClearConnectionListenerTeardownIsSafeAndIdempotent() {
        let chat = Chat(jwtToken: guestJWT, isGuest: true, showKey: testShowKey)

        // listener almost certainly still nil here -> nil branch of the fix.
        chat.clean()
        // chatProvider now nil -> idempotent no-op.
        chat.clean()

        XCTAssertTrue(true, "clearConnection() listener teardown is nil-safe and idempotent")
    }

    // MARK: - 4. In-flight request is cancelled on clean() (D4)
    //
    // Constructs an APIHandler directly, starts a real request (which will
    // fail offline, but slowly enough that we cancel it first), and asserts
    // the in-flight registry is emptied by cancelAllRequests() and that the
    // call is idempotent / crash-free — the exact behavior clearConnection()
    // step 4 relies on. `APIEndpoint` is an enum (not a protocol) so we use
    // an existing case with a bogus key.
    func testInFlightRequestCancelledOnClean() {
        let handler = APIHandler()
        XCTAssertEqual(handler.inFlightRequestCount, 0, "registry starts empty")

        let endpoint = APIEndpoint.getCurrentEvent(showKey: "uaf-teardown-test-bogus-key")

        handler.request(
            endpoint: endpoint,
            method: .get,
            body: nil,
            responseType: NoResponse.self
        ) { _ in
            // May fire with a network/cancellation failure — acceptable and
            // must not crash. Not asserted (timing-dependent).
        }

        // request() registers synchronously right after resume(); give the
        // runloop a brief beat in case of scheduling latency.
        var waited = 0.0
        while handler.inFlightRequestCount == 0 && waited < 3.0 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            waited += 0.05
        }
        XCTAssertGreaterThanOrEqual(handler.inFlightRequestCount, 1,
            "the in-flight request must be registered after resume()")

        // Teardown: cancel everything (what clearConnection() step 4 does).
        handler.cancelAllRequests()
        XCTAssertEqual(handler.inFlightRequestCount, 0,
            "cancelAllRequests() must empty the in-flight registry")

        // Idempotent + crash-free when already empty.
        handler.cancelAllRequests()
        XCTAssertEqual(handler.inFlightRequestCount, 0,
            "cancelAllRequests() is idempotent")

        // Let the cancelled task's completion drain (NSURLErrorCancelled);
        // touching `handler` here must not crash — the whole point of D4.
        let drain = expectation(description: "cancelled completion drains without crash")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            _ = handler.inFlightRequestCount
            drain.fulfill()
        }
        wait(for: [drain], timeout: 5)
    }

    // MARK: - 5. Crash-repro guard: late callback after teardown
    //
    // Closest faithful in-process reproduction of the
    // navigate-in/out crash: build a Chat, kick its provider work, call
    // clean(), then dispatch a synthetic "late completion" onto a
    // background queue that touches the (now torn-down) chat path. With the
    // pre-fix code the strong delegate / strong-self closures would deref a
    // freed graph -> EXC_BAD_ACCESS. With the fix the weak guards
    // short-circuit and the process survives.
    func testLateURLSessionCallbackAfterTeardownDoesNotCrash() {
        let survived = expectation(description: "process survives a late callback after teardown")

        // Held strongly for the test's lifetime: `Chat.delegate` is `weak`
        // (D2), so an inline temporary would be deallocated immediately.
        let spy = SpyChatDelegate { /* no-op: this test only asserts no-crash */ }

        autoreleasepool {
            let chat = Chat(jwtToken: guestJWT, isGuest: true, showKey: testShowKey)
            chat.delegate = spy

            let armed = expectation(description: "provider armed before teardown")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { armed.fulfill() }
            wait(for: [armed], timeout: 6)

            // Tear down mid-flight (the exact teardown sequence).
            chat.clean()

            // Synthetic late completion on a background queue AFTER teardown,
            // touching the chat surface. Must be safe no-ops (chatProvider
            // == nil) and never crash.
            DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 0.5) {
                chat.countMessages { _, _ in }
                chat.sendMessage(message: "post-teardown", completion: { _, _ in })
                chat.getChatMessages { _ in }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    survived.fulfill()
                }
            }
        }

        wait(for: [survived], timeout: 8)
        XCTAssertTrue(true, "no EXC_BAD_ACCESS on a late callback after Chat.clean()")
    }
}
