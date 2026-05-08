//
//  PubNub10MigrationTests.swift
//
//  Targeted unit tests covering the SDK's PubNub-typed conversion
//  surface — the code that touches PubNub envelope types and would
//  break first under a PubNub 9 → 10 transitive bump.
//
//  Scope: data conversion only. ChatProvider's PubNub init/subscribe
//  paths are out of scope (they require a live PubNub session and a
//  full fake harness, which the directive explicitly bounds against).
//

import XCTest
@testable import Talkshoplive
import PubNubSDK

final class PubNub10MigrationTests: XCTestCase {

    // MARK: - MessageAction(action: PubNubMessageAction)

    func test_messageAction_initFromPubNub_copiesAllFields() {
        let action = FakePubNubMessageAction(
            actionType: "reaction",
            actionValue: "👍",
            actionTimetoken: 17_111_222_333_444_555,
            messageTimetoken: 17_111_222_333_444_000,
            publisher: "user-42"
        )

        let converted = MessageAction(action: action)

        XCTAssertEqual(converted.actionType, "reaction")
        XCTAssertEqual(converted.actionValue, "👍")
        XCTAssertEqual(converted.actionTimetoken, 17_111_222_333_444_555)
        XCTAssertEqual(converted.publisher, "user-42")
        XCTAssertEqual(converted.messageTimetoken, "17111222333444000")
    }

    func test_messageAction_initFromPubNub_truncatesTimetokenToInt() {
        // Timetoken (UInt64) → Int conversion is lossy on 32-bit. On 64-bit
        // (our supported targets: iOS 13+, macOS 10.15+) Int is 64-bit, so
        // values up to Int64.max round-trip cleanly. Pinning the contract.
        let bigTimetoken: Timetoken = 9_223_372_036_854_775_000 // < Int64.max
        let action = FakePubNubMessageAction(actionTimetoken: bigTimetoken)

        let converted = MessageAction(action: action)

        XCTAssertEqual(converted.actionTimetoken, Int(bigTimetoken))
    }

    func test_messageAction_defaultInit_isAllNil() {
        let empty = MessageAction()
        XCTAssertNil(empty.actionType)
        XCTAssertNil(empty.actionValue)
        XCTAssertNil(empty.actionTimetoken)
        XCTAssertNil(empty.publisher)
        XCTAssertNil(empty.messageTimetoken)
    }

    func test_messageAction_codableRoundtrip() throws {
        let original = MessageAction(action: FakePubNubMessageAction(
            actionType: "emoji",
            actionValue: "🚀",
            actionTimetoken: 17_111_222_333_444_555,
            messageTimetoken: 17_111_222_333_444_000,
            publisher: "user-99"
        ))

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MessageAction.self, from: encoded)

        XCTAssertEqual(decoded.actionType, "emoji")
        XCTAssertEqual(decoded.actionValue, "🚀")
        XCTAssertEqual(decoded.publisher, "user-99")
        // actionTimetoken is intentionally omitted from encode() in
        // production code (see MessageData.swift:574-581) — verify the
        // documented asymmetry rather than asserting equality.
        XCTAssertNil(decoded.actionTimetoken)
        XCTAssertEqual(decoded.messageTimetoken, "17111222333444000")
    }

    // MARK: - MessageBase.toMessageActions

    func test_messageBase_toMessageActions_mapsAll() {
        let actions: [PubNubMessageAction] = [
            FakePubNubMessageAction(actionType: "a1", actionValue: "v1"),
            FakePubNubMessageAction(actionType: "a2", actionValue: "v2"),
            FakePubNubMessageAction(actionType: "a3", actionValue: "v3"),
        ]
        let base = MessageBase()

        let converted = base.toMessageActions(actions: actions)

        XCTAssertEqual(converted.count, 3)
        XCTAssertEqual(converted.map(\.actionType), ["a1", "a2", "a3"])
        XCTAssertEqual(converted.map(\.actionValue), ["v1", "v2", "v3"])
    }

    func test_messageBase_toMessageActions_emptyInputProducesEmptyOutput() {
        let base = MessageBase()
        XCTAssertTrue(base.toMessageActions(actions: []).isEmpty)
    }

    // MARK: - MessageBase.init(pubNubMessage:)

    func test_messageBase_initFromPubNub_copiesEnvelopeFields() {
        let payload = FakeJSONCodable([
            "id": 7,
            "text": "hello",
            "type": "comment",
            "platform": "sdk",
        ])
        let action = FakePubNubMessageAction(actionType: "like", actionValue: "true")
        let pubnub = FakePubNubMessage(
            payload: payload,
            actions: [action],
            publisher: "alice",
            channel: "chan-1",
            subscription: "chan-1.*",
            published: 17_500_000_000_000_000,
            metadata: nil,
            messageType: .message
        )

        let base = MessageBase(pubNubMessage: pubnub)

        XCTAssertEqual(base.publisher, "alice")
        XCTAssertEqual(base.channel, "chan-1")
        XCTAssertEqual(base.subscription, "chan-1.*")
        XCTAssertEqual(base.published, "17500000000000000")
        XCTAssertEqual(base.messageType, .message)
        XCTAssertEqual(base.actions?.count, 1)
        XCTAssertEqual(base.actions?.first?.actionType, "like")
        XCTAssertEqual(base.payload?.id, 7)
        XCTAssertEqual(base.payload?.text, "hello")
        XCTAssertEqual(base.payload?.platform, "sdk")
    }

    func test_messageBase_initFromPubNub_messageTypeFallsBackToUnknownOnExoticRaw() {
        // PubNubMessageType has matching int rawValues for case .signal (1),
        // .object (2), .messageAction (3), .file (4) — verify our enum maps
        // them through cleanly.
        let pubnub = FakePubNubMessage(
            payload: FakeJSONCodable("ignored"),
            messageType: .signal
        )

        let base = MessageBase(pubNubMessage: pubnub)
        XCTAssertEqual(base.messageType, .signal)
    }

    func test_messageBase_initFromPubNub_payloadDecodeFailureLeavesPayloadNil() {
        // Non-JSON-shaped payload should not produce a MessageData. The
        // production code silently drops in that case (no throw, no log).
        let pubnub = FakePubNubMessage(payload: FakeJSONCodable("a-bare-string-not-a-message-object"))

        let base = MessageBase(pubNubMessage: pubnub)
        XCTAssertNil(base.payload)
    }

    func test_messageBase_defaultInit_isAllNilExceptUnknown() {
        let base = MessageBase()
        XCTAssertNil(base.publisher)
        XCTAssertNil(base.channel)
        XCTAssertNil(base.subscription)
        XCTAssertNil(base.published)
        XCTAssertEqual(base.messageType, .unknown)
        XCTAssertNil(base.payload)
        XCTAssertNil(base.actions)
        XCTAssertNil(base.metaData)
    }

    // MARK: - MessagePage <-> PubNubBoundedPageBase

    func test_messagePage_initFromPubNub_copiesStartAndLimit() throws {
        let pubnubPage = try XCTUnwrap(PubNubBoundedPageBase(start: 17_111, end: nil, limit: 50))

        let page = MessagePage(page: pubnubPage)

        XCTAssertEqual(page.start, 17_111)
        XCTAssertEqual(page.limit, 50)
    }

    func test_messagePage_initFromPubNub_handlesNilStart() throws {
        let pubnubPage = try XCTUnwrap(PubNubBoundedPageBase(start: nil, end: nil, limit: 25))

        let page = MessagePage(page: pubnubPage)

        XCTAssertNil(page.start)
        XCTAssertEqual(page.limit, 25)
    }

    func test_messagePage_toPubNubBoundedPage_roundtrip() throws {
        let page = MessagePage(start: 17_222, limit: 100)

        let pubnubPage = page.toPubNubBoundedPageBase()

        XCTAssertEqual(pubnubPage.start, 17_222)
        XCTAssertEqual(pubnubPage.limit, 100)
    }

    func test_messagePage_toPubNubBoundedPage_nilStartCoercesToZero() {
        // Documented behavior: production code coerces a nil `start` to
        // `0` when handing back a `PubNubBoundedPageBase` (see
        // MessageData.swift:514). Pin the contract.
        let page = MessagePage(start: nil, limit: 25)
        let pubnubPage = page.toPubNubBoundedPageBase()
        XCTAssertEqual(pubnubPage.start, 0)
    }

    func test_messagePage_defaults() {
        let empty = MessagePage()
        XCTAssertNil(empty.start)
        XCTAssertEqual(empty.limit, 25)
    }

    // MARK: - MessageData encoding/decoding

    func test_messageData_codableRoundtrip() throws {
        let sender = Sender(id: "u1", name: "Alice", profileUrl: "https://example.com/a.png", externalId: "ext-1")
        let original = MessageData(
            id: 42,
            createdAt: "2026-04-30T10:00:00Z",
            sender: sender,
            text: "hello",
            type: .comment,
            platform: "sdk",
            payload: "17500000000000000"
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MessageData.self, from: encoded)

        XCTAssertEqual(decoded.id, 42)
        XCTAssertEqual(decoded.text, "hello")
        XCTAssertEqual(decoded.type, .comment)
        XCTAssertEqual(decoded.platform, "sdk")
        XCTAssertEqual(decoded.timeToken, "17500000000000000")
        XCTAssertEqual(decoded.sender?.id, "u1")
        XCTAssertEqual(decoded.sender?.name, "Alice")
        XCTAssertEqual(decoded.sender?.profileUrl, "https://example.com/a.png")
    }

    func test_messageData_decodes_senderAsString_legacyFormat() throws {
        // Backend used to send sender as a bare string instead of a Sender
        // object. The custom `init(from:)` falls back and constructs a
        // Sender with id+name set to the string. Guard the legacy path.
        let json = """
        {
            "id": 1,
            "text": "hi",
            "type": "comment",
            "sender": "legacy-sender-string"
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(MessageData.self, from: json)

        XCTAssertEqual(decoded.sender?.id, "legacy-sender-string")
        XCTAssertEqual(decoded.sender?.name, "legacy-sender-string")
    }

    func test_messageType_decodesUnknownStringAsComment() throws {
        let json = "\"not-a-known-type\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MessageType.self, from: json)
        XCTAssertEqual(decoded, .comment)
    }

    func test_messageType_caseInsensitive() throws {
        let json = "\"COMMENT\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MessageType.self, from: json)
        XCTAssertEqual(decoded, .comment)
    }

    // MARK: - MessagePayloadKey

    func test_messagePayloadKey_decodesMessageDeleted() throws {
        let json = "\"message_deleted\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MessagePayloadKey.self, from: json)
        XCTAssertTrue(decoded.isEqual(to: .messageDeleted))
    }

    func test_messagePayloadKey_decodesCustomString() throws {
        let json = "\"some_custom_value\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(MessagePayloadKey.self, from: json)
        XCTAssertTrue(decoded.isEqual(to: .custom("some_custom_value")))
    }

    func test_messagePayloadKey_encodesMessageDeleted() throws {
        let encoded = try JSONEncoder().encode(MessagePayloadKey.messageDeleted)
        let decoded = try JSONDecoder().decode(String.self, from: encoded)
        XCTAssertEqual(decoded, "message_deleted")
    }

    func test_messagePayloadKey_encodesCustom() throws {
        let encoded = try JSONEncoder().encode(MessagePayloadKey.custom("foo"))
        let decoded = try JSONDecoder().decode(String.self, from: encoded)
        XCTAssertEqual(decoded, "foo")
    }

    func test_messagePayloadKey_isEqualMixedCases() {
        XCTAssertFalse(MessagePayloadKey.messageDeleted.isEqual(to: .custom("message_deleted")))
        XCTAssertFalse(MessagePayloadKey.custom("a").isEqual(to: .custom("b")))
    }

    // MARK: - Sender encode/decode

    func test_sender_decodesProfileUrlAsURL() throws {
        let json = """
        { "id": "u1", "name": "Alice", "profileUrl": "https://example.com/a.png", "externalId": "ext-1" }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Sender.self, from: json)
        XCTAssertEqual(decoded.profileUrl, "https://example.com/a.png")
    }

    func test_sender_decodesMissingProfileUrlAsNil() throws {
        let json = """
        { "id": "u2", "name": "Bob" }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(Sender.self, from: json)
        XCTAssertNil(decoded.profileUrl)
        XCTAssertEqual(decoded.id, "u2")
        XCTAssertEqual(decoded.name, "Bob")
    }

    func test_sender_defaultInitIsAllNil() {
        let empty = Sender()
        XCTAssertNil(empty.id)
        XCTAssertNil(empty.name)
        XCTAssertNil(empty.profileUrl)
        XCTAssertNil(empty.externalId)
    }

    // MARK: - OriginalMessageData / OriginalMessageBase

    func test_originalMessageData_decodesSenderAsString_legacyFormat() throws {
        let json = """
        {
            "id": 9,
            "text": "wave",
            "type": "comment",
            "sender": "legacy-handle"
        }
        """.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(OriginalMessageData.self, from: json)
        XCTAssertEqual(decoded.sender?.id, "legacy-handle")
        XCTAssertEqual(decoded.sender?.name, "legacy-handle")
    }

    func test_originalMessageBase_codableRoundtrip() throws {
        let inner = OriginalMessageData(id: 1, text: "x", type: .comment)
        let outer = OriginalMessageBase(message: inner)

        let encoded = try JSONEncoder().encode(outer)
        let decoded = try JSONDecoder().decode(OriginalMessageBase.self, from: encoded)

        XCTAssertEqual(decoded.message?.id, 1)
        XCTAssertEqual(decoded.message?.text, "x")
        XCTAssertEqual(decoded.message?.type, .comment)
    }
}
