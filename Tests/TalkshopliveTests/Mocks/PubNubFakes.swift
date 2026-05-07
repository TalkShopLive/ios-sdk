//
//  PubNubFakes.swift
//
//  Minimal stand-ins for PubNubSDK 10.x protocol types so we can
//  test the TSL conversion layer (`MessageBase.init(pubNubMessage:)`,
//  `MessageAction.init(action:)`, `MessagePage.init(page:)`) without
//  a live PubNub connection. These are scoped to the conversion
//  surface only — not a general-purpose PubNub fake.
//

import Foundation
@testable import Talkshoplive
import PubNubSDK

struct FakePubNubMessage: PubNubMessage {
    var payload: JSONCodable
    var actions: [PubNubMessageAction]
    var publisher: String?
    var channel: String
    var subscription: String?
    var published: Timetoken
    var metadata: JSONCodable?
    var messageType: PubNubMessageType
    var customMessageType: String?
    var error: PubNubError?

    init(
        payload: JSONCodable,
        actions: [PubNubMessageAction] = [],
        publisher: String? = "fake-publisher",
        channel: String = "fake-channel",
        subscription: String? = nil,
        published: Timetoken = 17_000_000_000_000_000,
        metadata: JSONCodable? = nil,
        messageType: PubNubMessageType = .message,
        customMessageType: String? = nil,
        error: PubNubError? = nil
    ) {
        self.payload = payload
        self.actions = actions
        self.publisher = publisher
        self.channel = channel
        self.subscription = subscription
        self.published = published
        self.metadata = metadata
        self.messageType = messageType
        self.customMessageType = customMessageType
        self.error = error
    }

    init(from other: PubNubMessage) throws {
        self.init(
            payload: other.payload,
            actions: other.actions,
            publisher: other.publisher,
            channel: other.channel,
            subscription: other.subscription,
            published: other.published,
            metadata: other.metadata,
            messageType: other.messageType,
            customMessageType: other.customMessageType,
            error: other.error
        )
    }
}

struct FakePubNubMessageAction: PubNubMessageAction {
    let actionType: String
    let actionValue: String
    let actionTimetoken: Timetoken
    let messageTimetoken: Timetoken
    let publisher: String
    let channel: String
    let subscription: String?
    let published: Timetoken?

    init(
        actionType: String = "reaction",
        actionValue: String = "❤",
        actionTimetoken: Timetoken = 17_000_000_000_000_001,
        messageTimetoken: Timetoken = 17_000_000_000_000_000,
        publisher: String = "fake-publisher",
        channel: String = "fake-channel",
        subscription: String? = nil,
        published: Timetoken? = nil
    ) {
        self.actionType = actionType
        self.actionValue = actionValue
        self.actionTimetoken = actionTimetoken
        self.messageTimetoken = messageTimetoken
        self.publisher = publisher
        self.channel = channel
        self.subscription = subscription
        self.published = published
    }

    init(from other: PubNubMessageAction) throws {
        self.actionType = other.actionType
        self.actionValue = other.actionValue
        self.actionTimetoken = other.actionTimetoken
        self.messageTimetoken = other.messageTimetoken
        self.publisher = other.publisher
        self.channel = other.channel
        self.subscription = other.subscription
        self.published = other.published
    }
}

struct FakeJSONCodable: JSONCodable, Codable {
    let value: AnyJSON

    init(_ dict: [String: Any]) {
        self.value = AnyJSON(dict)
    }

    init(_ string: String) {
        self.value = AnyJSON(string)
    }

    var codableValue: AnyJSON { value }
}
