# TSL iOS SDK

This is the official TSL iOS SDK repository.

TSL takes care of the infrastructure and APIs needed for live streaming of different types of shows for various channels. Work on your app's logic and let TSL handle live streaming of shows, sending and receiving messages, and reactions.

* [Requirements](#requirements)
* [Get Keys](#get-keys)
* [Set Up Your Project](#set-up-your-project)
* [Configure TSL-iOS-SDK](#configure-tsl-ios-sdk)
* [Shows](#shows)

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
4. Use the `Up to Next Major Version` rule and hit the Next button.

For more information, see Apple's guide on [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Configure TSL-iOS-SDK

1. Import the module named `Talkshoplive` inside your AppDelegate:

    ```swift
    import UIKit
    import Talkshoplive // <- Here is our Talkshoplive module import.
    ```

## Shows

### Overview

The TSL iOS SDK provides methods for fetching details of a specific show and its current event, enabling you to get show and current event details in your app.

### Methods

#### `getDetails(showId:completion:)`

Get detailed information about a specific show.

- Parameters:
  - `showId`: The unique identifier of the show.
  - `completion`: A closure that will be called once the show details are fetched. It takes a `Result` enum containing either the `ShowData` on success or an `Error` on failure.

```swift
let showInstance = Talkshoplive.Show()
showInstance.getDetails(showId: "yourShowId") { result in
    switch result {
    case .success(let show):
        print("Show details: \(show)")
    case .failure(let error):
        // Handle error case
        print("Error fetching show details: \(error)")
    }
}
```

#### `getStatus(showId:completion:)`

Get the current event of a show.

- Parameters:
  - `showId`: The unique identifier of the show.
  - `completion`: A closure that will be called once the show details are fetched. It takes a `Result` enum containing either the `ShowData` on success or an `Error` on failure.

```swift
let showInstance = Talkshoplive.Show()
showInstance.getDetails(showId: "yourShowId") { result in
    switch result {
    case .success(let eventData):
        print("Show's current event' details: \(eventData)")
    case .failure(let error):
        // Handle error case
        print("Error fetching show's current event details: \(error)")
    }
}
```
    
## Run the Tests: 
1. In swift package manager, navigate to the relatedFile_tests target. After that Click the "Play" button or use the shortcut Cmd + U to build and run the tests.
2. After the tests are run, you can view the results in the Test navigator.
3. Successful tests will be marked with a green checkmark, and failed tests will be marked with a red X. 
4. You can click on each test to see detailed output.


## Support

If you **need help** or have a **general question**, contact <support@talkshoplive.com>.
