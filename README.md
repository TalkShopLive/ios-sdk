# TSL iOS SDK

This is the official TSL iOS SDK repository.

TSL takes care of the infrastructure and APIs needed for live streaming of different types of shows for various channels. Work on your app's logic and let TSL handle live streaming of shows, sending and receiving messages, and reactions.

* [Requirements](#requirements)
* [Get Keys](#get-keys)
* [Set Up Your Project](#set-up-your-project)
* [Configure TSL-iOS-SDK](#configure-tsl-ios-sdk)
* [Shows](#shows)
* [Chats](#chats)

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
let showInstance = Talkshoplive.Show()
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

#### `getStatus(showKey:completion:)`

Get the current event of a show.

- Parameters:
    - `showKey`: The unique identifier of the show.
    - `completion`: A closure that will be called once the show details are fetched. It takes a `Result` enum containing either the `ShowData` on success or an `Error` on failure.

```
let showInstance = Talkshoplive.Show()
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

#### `init(jwtToken:isGuest:showKey:mode:refresh:)`

Initializes a new instance of the Chat class.

- Parameters:
  - `jwtToken`: Generated JWT token
    - Example: eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MTAwMjM0NDEsImp0aSI6InRXc3NBd1Nvb2VoaHp5UTA5NUV1eXk9PSJ9.XtPM3iibdTt-fp8fhm2Gh2T7X0XXuUuIPY17bW648Gk
  - `isGuest`: A boolean indicating whether the user is a guest user (true) or a federated user (false).
  - `showKey`: show_key for which you want to subscribe to the channel.  

```
let chatInstance = Talkshoplive.Chat(jwtToken: "YourJWTToken", isGuest:true/false, showKey: "YourShowKey")

```

#### `sendMessage(message:)`

Use initialized instance of the Chat class and sends a message using that instance.

- Parameters:
  - `message`: The text message to be sent.

- Send Message
```
self.chatInstance.sendMessage(message: "Your Message Here")
```

- Recieve New message event listener
```
class ContentViewModel: ObservableObject, ChatDelegate {
    func onNewMessage(_ message: MessageData) {
        // Handle the received message
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
            if let actions = message.actions, actions.count > 0 {
                for action in actions {
                    print("Message Action:", action)
                }
            }
        }            
    case .failure(let error):
        // Handle error case
        print("Error: \(error.localizedDescription)")
    }
})
```
#### `updateUser(jwtToken:isGuest:completion:)`

Use initialized instance of the Chat class and update use with updated jwtToken

- Parameters:
  - `jwtToken`: Updated JWT token 
  - `isGuest`: A boolean indicating whether the user will updated to guest user (true) or a federated user (false).

```
self.chatInstance.updateUser(jwtToken: "Your Updated JWTToken", isGuest:true/false) { status, error in
    if status {
        print("User Updated successfully!")
    } else {
        print("Error occurred: \(error.localizedDescription)")
    }
}
```
    
## Run the Tests: 
1. In  package manager, navigate to the relatedFile_tests target. After that Click the "Play" button or use the shortcut Cmd + U to build and run the tests.
2. After the tests are run, you can view the results in the Test navigator.
3. Successful tests will be marked with a green checkmark, and failed tests will be marked with a red X. 
4. You can click on each test to see detailed output.


## Support

If you **need help** or have a **general question**, contact <support@talkshoplive.com>.
