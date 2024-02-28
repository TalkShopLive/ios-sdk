//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public class Chat {
    private let pubnub: PubNub
       private let channel: String

    public init(publishKey: String, subscribeKey: String, userId: String, channel: String, authToken: String) {
        let config = PubNubConfiguration(publishKey: publishKey, subscribeKey: subscribeKey, uuid: userId, authToken: authToken)
           self.pubnub = PubNub(configuration: config)
           self.channel = channel
       }

    public func subscribe(onMessage: @escaping (Any?) -> Void) {
        let listener = SubscriptionListener(queue: .main)
        listener.didReceiveSubscription = { event in
            switch event {
            case .messageReceived(let message):
                print("The \(message.channel) channel received a message at \(message.published)")
                if let subscription = message.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                }
                print("The message is \(message.payload) and was sent by \(message.publisher ?? "")")
            case .signalReceived(let signal):
                  print("The \(signal.channel) channel received a message at \(signal.published)")
                  if let subscription = signal.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                  }
                  print("The signal is \(signal.payload) and was sent by \(signal.publisher ?? "")")
            case .connectionStatusChanged(_):
                print("The connectionStatusChanged")
            case .subscriptionChanged(_):
                print("The subscriptionChanged")
            case .presenceChanged(_):
                print("The presenceChanged")
            case .uuidMetadataSet(_):
                print("The uuidMetadataSet")
            case .uuidMetadataRemoved(metadataId: let metadataId):
                print("The uuidMetadataRemoved")
            case .channelMetadataSet(_):
                print("The channelMetadataSet")
            case .channelMetadataRemoved(metadataId: let metadataId):
                print("The channelMetadataRemoved")
            case .membershipMetadataSet(_):
                print("The membershipMetadataSet")
            case .membershipMetadataRemoved(_):
                print("The membershipMetadataRemoved")
            case .messageActionAdded(_):
                print("The messageActionAdded")
            case .messageActionRemoved(_):
                print("The messageActionRemoved")
            case .fileUploaded(_):
                print("The fileUploaded")
            case .subscribeError(_):
                print("The subscribeError")
            }
        }
        pubnub.add(listener)
        pubnub.subscribe(to: [channel])
    }

    public func publish(message: String) {
           pubnub.publish(channel: channel, message: message) { result in
               switch result {
               case let .success(timetoken):
                   print("Publish Response at \(timetoken)")
               case let .failure(error):
                   print("Publishing Error: \(error.localizedDescription)")
               }
           }
       }
    
}
//    // MARK: - Properties
//    private let showKey: String
//    private let mode: String
//    private let refresh: String
//
//    // MARK: - Initializer
//
//    public init(jwtToken:String,isGuest:Bool,showKey: String, mode: String, refresh: String) {
//        // Initialize properties
//        self.showKey = showKey
//        self.mode = mode
//        self.refresh = refresh
//        
//        let _ = ChatProvider(jwtToken: jwtToken, isGuest: isGuest)
//    }


