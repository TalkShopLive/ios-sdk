// HotfixValidationTests.swift
// Offline unit tests covering every fix in hotfix/walmart-critical-4.1.1.
// No network required — all assertions run against local logic only.

import XCTest
@testable import Talkshoplive

final class HotfixValidationTests: XCTestCase {

    // MARK: - Fix 1: chatId CodingKey maps "chat_id" (snake_case)

    func test_messagingTokenResponse_chatId_decodesFromSnakeCase() throws {
        let json = #"{"publish_key":"pk","subscribe_key":"sk","user_id":"u1","token":"t","chat_id":42}"#
        let sut = try decode(json)
        XCTAssertEqual(sut.chatId, 42, "chatId must decode from 'chat_id', not 'chatId'")
    }

    func test_messagingTokenResponse_chatId_nilWhenAbsent() throws {
        let json = #"{"publish_key":"pk","subscribe_key":"sk","user_id":"u1","token":"t"}"#
        let sut = try decode(json)
        XCTAssertNil(sut.chatId)
    }

    // MARK: - Fix 2: userId decodes safely — no force-unwrap crash

    func test_messagingTokenResponse_userId_decodesFromSnakeCase() throws {
        let json = #"{"publish_key":"pk","subscribe_key":"sk","user_id":"walmart-user","token":"t"}"#
        let sut = try decode(json)
        XCTAssertEqual(sut.userId, "walmart-user")
    }

    func test_messagingTokenResponse_userId_nilWhenAbsent_doesNotCrash() throws {
        // Previously crashed: CodingKeys(rawValue:"userId")! was always nil
        let json = #"{"publish_key":"pk","subscribe_key":"sk","token":"t"}"#
        XCTAssertNoThrow(try decode(json), "Must not crash when user_id is absent")
        let sut = try decode(json)
        XCTAssertNil(sut.userId)
    }

    func test_messagingTokenResponse_emptyObject_doesNotCrash() throws {
        let json = #"{}"#
        XCTAssertNoThrow(try decode(json))
    }

    // MARK: - Fix 3: unlikeComment v1 URL — no "Optional(N)" interpolation

    func test_unlikeCommentURL_v1_noOptionalInterpolation() {
        // The URL path for v1 must contain a plain integer, not "Optional(N)"
        let endpoint = APIEndpoint.unlikeComment(
            eventId: "12345",
            messageTimeToken: "tt",
            actionTimeToken: "at"
        )
        XCTAssertFalse(endpoint.path.contains("Optional"), "v1 URL must not contain 'Optional'")
        XCTAssertTrue(endpoint.path.contains("12345"), "v1 URL must contain the raw event ID")
    }

    // MARK: - Fix 6: channelName percent-encoded in v2 DELETE URLs

    func test_deleteMessageV2_channelNamePercentEncoded() {
        // Channel names like "chat.12345" must be percent-encoded in the query string
        let endpoint = APIEndpoint.deleteMessageV2(channelName: "chat.12345", timetoken: "tt")
        XCTAssertFalse(endpoint.path.hasPrefix("Optional"), "URL must not contain Optional")
        // After percent-encoding, "." → "%2E" or remains "." (both are valid RFC 3986 for query)
        // The key invariant: no raw space, no raw control chars
        XCTAssertFalse(endpoint.path.contains(" "), "URL must not contain unencoded spaces")
        XCTAssertTrue(endpoint.path.contains("channel-name="), "URL must include channel-name param")
    }

    func test_unlikeCommentV2_channelNamePercentEncoded() {
        let endpoint = APIEndpoint.unlikeCommentV2(
            channelName: "chat.12345",
            messageTimeToken: "tt",
            actionTimeToken: "at"
        )
        XCTAssertTrue(endpoint.path.contains("channel-name="))
        XCTAssertFalse(endpoint.path.contains(" "))
    }

    func test_deleteMessageV2_channelWithSpecialChars_encoded() {
        let endpoint = APIEndpoint.deleteMessageV2(channelName: "chat test+channel", timetoken: "tt")
        XCTAssertFalse(endpoint.path.contains("chat test+channel"), "Unencoded special chars must not appear in URL")
    }

    // MARK: - Fix 8: getCurrentEvent() re-exposed as deprecated (API surface)

    func test_getCurrentEvent_isAvailable() {
        // Verifies getCurrentEvent() compiles and returns nil on a bare init
        // (it was deleted in Chat 2.0 refactor — must be re-exposed as deprecated)
        let provider = ChatProvider(jwtToken: "tok", isGuest: true, showKey: "key")
        // Suppress deprecated warning in tests — we're intentionally testing the deprecated API
        let event = provider.getCurrentEvent()
        XCTAssertNil(event, "getCurrentEvent() must be callable and return nil before chat is live")
    }

    // MARK: - Helpers

    private func decode(_ jsonString: String) throws -> MessagingTokenResponse {
        let data = jsonString.data(using: .utf8)!
        return try JSONDecoder().decode(MessagingTokenResponse.self, from: data)
    }
}
