# TSL iOS SDK

This is the official TSL iOS SDK repository.

TSL takes care of the infrastructure and APIs needed for live streaming of different types of shows for various channels. Work on your app's logic and let TSL handle live streaming of shows, sending and receiving messages, and reactions.

* [Requirements](#requirements)
* [Get Keys](#get-keys)
* [Set Up Your Project](#set-up-your-project)
* [Configure TSL-iOS-SDK](#configure-tsl-ios-sdk)
* [Shows](#shows)
* [Chats](#chats)
* [Collect](#collect)

## Requirements

* iOS 15.0+ / macOS 14.0+
* Xcode 14+
* Swift 5+

The TSL iOS SDK contains external dependencies of PubNub SDK.

## Get Keys

You will need the publish and subscribe keys to authenticate your app. Get your keys from the backend.

## Set Up Your Project

You have several options to set up your project using Swift Package Manager.

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Create or open your project inside Xcode.
2. Navigate to File > Swift Packages > Add Package Dependency.
3. Search for Talkshoplive and select the Swift package owned by TSL, and hit the Next button.
4. Use the `given version` and hit the Next button.

For more information, see Apple's guide on [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Configure TSL-iOS-SDK

1. Import the module named `Talkshoplive` inside your AppDelegate:

    ```
    import Talkshoplive // <- Here is our Talkshoplive module import.
    ```
    
2. Initialize the SDK using clientKey:
   
   - Parameters:
       - `clientKey`: Given secured client key.
       - `debugMode`: Print console logs if true
       - `testMode`: Switch to staging if true

   ```
   let TSL = Talkshoplive.TalkShopLive(clientKey: "YourClientKey", debugMode: true/false, testMode: true/false)

    ```
    
## Shows

### Overview

The TSL iOS SDK provides methods for fetching details of a specific show and its current event, enabling you to get show and current event details in your app.

### Methods
    
#### `getDetails(showKey:completion:)`

Get detailed information about a specific show.

- Parameters:
    - `showKey`: The unique identifier of the show.
    - `completion`: A closure that will be called once the show details are fetched. It takes a `Result` enum containing either the `ShowData` on success or an `Error` on failure.

```
let showInstance = Talkshoplive.Show.shared
showInstance.getDetails(showKey: "yourShowKey") { result in
    switch result {
    case .success(let show):
        print("Show details: \(show)")
    case .failure(let error):
        // Handle error case
        print("Error fetching show details: \(error)")
    }
}
```

#### `getProducts(showKey:preLive:completion:)`

Get Products list from specific show's details.

- Parameters:
    - `showKey`: The unique identifier of the show.
    - `preLive`(optional): A flag indicating whether the request is related to pre products. Default is `false`.
    - `completion`: A closure that will be called once the products are fetched. It takes a `Result` enum containing either the `[ProductData]` on success or an `Error` on failure.

```
showInstance.getProducts(showKey: "yourShowKey", preLive: "true/false") { result in
    switch result {
    case .success(let products):
        print("Products: \(products)")
        
        //Please use following to find product's variants information
        for i in products {
            print("Product Details", i)
            if let variants = i.variants, variants.count > 0 {
                for j in variants {
                    print("SKU", (i.sku ?? ""))
                }
            }
        }
    case .failure(let error):
        // Handle error case
        print("Error fetching products list: \(error)")
    }
}
```

#### `getStatus(showKey:completion:)`

Get the current event of a show.

- Parameters:
    - `showKey`: The unique identifier of the show.
    - `completion`: A closure that will be called once the show details are fetched. It takes a `Result` enum containing either the `ShowData` on success or an `Error` on failure.

```
let showInstance = Talkshoplive.Show.shared
showInstance.getStatus(showKey: "YourShowKey") { result in
    switch result {
    case .success(let eventData):
        print("Show's current event' details: \(eventData)")
    case .failure(let error):
        // Handle error case
        print("Error fetching show's current event details: \(error)")
    }
}
```

## Chats

### Overview

The TSL iOS SDK provides methods for fetching details of a specific current event, enabling you to get chat features.

### Methods

#### `init(jwtToken:isGuest:showKey:completion:)`

Initializes a new instance of the Chat class and confirm the delegate to recieve chat events.

- Parameters:
  - `jwtToken`: Generated JWT token
    - Example: eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MTAwMjM0NDEsImp0aSI6InRXc3NBd1Nvb2VoaHp5UTA5NUV1eXk9PSJ9.XtPM3iibdTt-fp8fhm2Gh2T7X0XXuUuIPY17bW648Gk
  - `isGuest`: A boolean indicating whether the user is a guest user (true) or a federated user (false).
  - `showKey`: show_key for which you want to subscribe to the channel.  
  - `completion`: (optional)
      - `status`: A boolean value indicating whether token created successfully or not.
      - `error`: An optional error that occurred during the token creation process, if any.

```
let chatInstance = Talkshoplive.Chat(jwtToken: "YourJWTToken", isGuest:true/false, showKey: "YourShowKey")
chatInstance.delegate = someContentViewModel

```

#### `sendMessage(message:)`

Use initialized instance of the Chat class and sends a message using that instance.

- Parameters:
  - `message`: The text message to be sent.
  - `type`: Default will be "comment", Other types are `giphy` and `question`.
  - `aspectRatio`: When type is "giphy", aspectRatio is mandatory.
  
- Completion:
  - `status`: A boolean value indicating whether the message was sent successfully or not.
  - `error`: An optional error that occurred during the sending process, if any.

- Send Message
```
self.chatInstance.sendMessage(message: newMessage, completion: {status, error in
    if status {
        print("Message Sent!", status)
    } else {
        //If Token is revoked, it will return "PERMISSION_DENIED"
        //If Token is expired, it will return "CHAT_TOKEN_EXPIRED"
        print("Message Sending Failed: \(error.localizedDescription)")
    }
}
```

- Send Giphy
```
self.chatInstance.sendMessage(message: "GiphyId", type: .giphy, aspectRatio: "GiphyWidth/GiphyHeight",completion: {status, error in
    if status {
        print("Giphy Sent!", status)
    } else {
        //If aspectRatio will be missing, it will return "MESSAGE_SENDING_GIPHY_DATA_NOT_FOUND"
        //If Token is revoked, it will return "PERMISSION_DENIED"
        print("Giphy Sending Failed: \(error.localizedDescription)")
    }
}
```

- Recieve New message event listener
```
class ContentViewModel: ObservableObject, ChatDelegate {
    func onNewMessage(_ message: MessageData) {
        // Handle the received message
        print("Recieved New Message", message)
        
        //If it's threaded message, it will have original message details
        if let originalMessage = message.payload?.original?.message {
            print("Original message's sender details", originalMessage.sender)
            print("Original message details", originalMessage.text)
        }
        
        //When MessageType is "giphy"
        if message.payload?.type == .giphy {
            print("Giphy ID", message.payload?.text)
            //Use giphyId with respective giphy URL to load the gif.
        }
    }
}

```

#### `deleteMessage(timeToken:)`


- Parameters:
  - `timeToken `: The time token when message was published.
  
- Completion:
  - `status`: A boolean value indicating whether the message was deleted successfully or not.
  - `error`: An optional error that occurred during the deletion process, if any.

- Delete Message
```
self.chatInstance.deleteMessage(timeToken: timetoken, completion: { status, error in
        if status {
            print("Message Deleted!")
        } else {
            //If Token is revoked, it will return "PERMISSION_DENIED"
            //If Token is expired, it will return "CHAT_TOKEN_EXPIRED"
            print("Message Deletion Failed : “\(error.localizedDescription))
        }
}
```

- Recieve Delete message event listener
```
class ContentViewModel: ObservableObject, ChatDelegate {
    func onDeleteMessage(_ message: Talkshoplive.MessageBase) {
        // Handle the deleted message.
    }
}

```

#### `getChatMessages(page:includeActions:includeMeta:includeUUID:completion:)`

Use to retrieve messages for a specific page, including or excluding actions, metadata, and UUID in the response.

- Parameters:
  - `page`: Specifies the page from which to retrieve chat history. If not provided (set to nil), the method will fetch chat history without specifying a particular page.
  - `includeActions`: Defaults to true. Set to false if you wish to exclude actions from the response.
  - `includeMeta`: Defaults to true. Set to false if you want to omit metadata from the response.
  - `includeUUID`: Defaults to true. Set to false if you prefer not to include UUID in the response.
  - `completion`: A closure invoked upon fetching chat history. It receives a Result enum with an array of `MessageBase` on success or an `Error` on failure.
  
```
self.chatInstance.getChatMessages(page: page, completion: { result in
    switch result {
    case let .success((messageArray, nextPage)):
        // print("Next Page:", nextPage)
        // print("Received chat messages:", messageArray)
        
        // Access the actions if 'includeActions' is set to true
        for message in messageArray {
            //If it's threaded message, it will have original message details
            if let originalMessage = message.payload?.original?.message {
                print("Original message's sender details", originalMessage.sender)
                print("Original message details", originalMessage.text)
            }
            
            if let actions = message.actions, actions.count > 0 {
                for action in actions {
                    print("Message Action:", action)
                }
            }
        }            
    case .failure(let error):
        // Handle error case
        //If Token is revoked, it will return "PERMISSION_DENIED"
        //If Token is expired, it will return "CHAT_TOKEN_EXPIRED"
        print("Error: \(error.localizedDescription)")
    }
})
```

#### `clean()`

Use to clear all resources associated with the chat instance, including connections and delegates.

```
self.chatInstance.clean()
```

#### `updateUser(jwtToken:isGuest:completion:)`

Use initialized instance of the Chat class and update use with updated jwtToken

- Parameters:
  - `jwtToken`: Updated JWT token 
  - `isGuest`: A boolean indicating whether the user will updated to guest user (true) or a federated user (false).
  - `completion`:
      - `status`: A boolean value indicating whether the user was updated successfully or not.
      - `error`: An optional error that occurred during the sending process, if any.

```
self.chatInstance.updateUser(jwtToken: "Your Updated JWTToken", isGuest:true/false) { status, error in
    if status {
        print("User Updated successfully!")
    } else {
        print("Error occurred: \(error.localizedDescription)")
    }
}
```

#### `countMessages(completion:)`

Use to retrieve the count of messages using a chat instance.

- `completion`:
  - `count`: An integer value representing the total count of messages.
  - `error`: An optional error that occurred during the counting process, if any.

```
self.chatInstance.countMessages({ count, error in
    if let error = error {
        //If Token is revoked, it will return "PERMISSION_DENIED"
        //If Token is expired, it will return "CHAT_TOKEN_EXPIRED"
        print(error.localizedDescription)
        print("Error fetching messages count: \(error.localizedDescription))"
    } else {
        print("Message Count : \(count)")
    }
})
```

#### `likeComment(timeToken:completion:)`

Use to like a message using a chat instance.

- Parameters:
  - `timeToken `: The time token when message was published.
  
- Completion:
  - `status`: A boolean value indicating whether the message was liked successfully or not.
  - `error`: An optional error that occurred during the like comment process, if any.

```
self.chatInstance.likeComment(timeToken: "timetoken", completion: { status, error in
    if status {
        print("Liked comment Successfully", status)
    } else {
        print("Liked comment Error", error?.localizedDescription ?? "")
    }
})
```

- Recieve Like comment event listener
```
class ContentViewModel: ObservableObject, ChatDelegate {
    func onLikeComment(_ messageAction: Talkshoplive.MessageAction) {
        // Handle the liked message action.
    }
}

```


#### ` UnlikeComment(timeToken:actionTimeToken:completion:)`

Use to Unlike a message using a chat instance.

- Parameters:
  - `timeToken `: The time token when message was published.
  - `actionTimeToken `: The time token when message was liked.
  
- Completion:
  - `status`: A boolean value indicating whether the message was unliked successfully or not.
  - `error`: An optional error that occurred during the unlike comment process, if any.

```
self.chatInstance.UnlikeComment(timeToken: "timetoken", actionTimeToken: "actionTimetoken", completion: { status, error in
    if status {
        print("Unliked comment Successfully", status)
    } else {
        print("Unliked comment Error", error?.localizedDescription ?? "")
    }
})
```

- Recieve Unlike comment event listener
```
class ContentViewModel: ObservableObject, ChatDelegate {
    func onUnlikeComment(_ messageAction: MessageAction) {
        // Handle the Unliked message action.
    }
}

```

#### `onStatusChange(error:)`

Use to listen event when token is revoked.

```
func onStatusChange(error: Talkshoplive.APIClientError) {
    
    switch error {
    case .PERMISSION_DENIED:
        //If Token is revoked
        print("Permission Denied")
    case .CHAT_TOKEN_EXPIRED:
        //If Token is expired
        print("Chat token expired")
    case .CHAT_TIMEOUT:
        //Chat timeout
        print("Chat Timeout")
    case .CHAT_CONNECTION_ERROR:
        //connection get dismiss and tried to reconnect and fails
        print("Chat connection error")
    default:
        break
    }
}
```

## Collect

### Overview

The Collect functionality logs user actions related to shows and product views. By capturing these events, the SDK tracks user engagement and interactions within the application, enabling you to analyze user behavior and improve the overall user experience.

### Initialization
    
#### `Collect(show:userId:)`

This initializer creates a Collect instance using a show details object and, optionally, a user identifier.

- Parameters:
    - `show`: An object containing the show details.
    - `userId`: A string representing the user identifier associated with the action.

```
// Event data instance, typically retrieved from show.getStatus()
var eventObject : Talkshoplive.EventData? 

// Initialize a Collect instance using the current event data and a user ID
let collectInstance = Collect(event: eventInstance, userId: "UserId")

// Track a specific user action by calling the collect method with an action name, current video time (in seconds), and optional variantId and productKey.
// Pass variantId and productKey only for product-related actions.
collectInstance.collect(actionName: .actionName, videoTime: currentVideoTimeInSeconds, variantId: variantId, productKey: productKey)

```
    
## Run the Tests: 
1. In  package manager, navigate to the relatedFile_tests target. After that Click the "Play" button or use the shortcut Cmd + U to build and run the tests.
2. After the tests are run, you can view the results in the Test navigator.
3. Successful tests will be marked with a green checkmark, and failed tests will be marked with a red X. 
4. You can click on each test to see detailed output.


## Support

If you **need help** or have a **general question**, contact <support@talkshoplive.com>.
