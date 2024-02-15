# TSL iOS SDK

This is the official TSL iOS SDK repository.

TSL takes care of the infrastructure and APIs needed for the Live streaming of the diffrent types of shows for different channels. Work on your app's logic and let TSL handle live streaming of shows , sending and receiving messages and reaction.

* [Requirements](#requirements)
* [Get keys](#get-keys)
* [Set up your project](#set-up-your-project)
* [Configure TSL-iOS-SDK](#configure-TSL-iOS-SDK)
* [Publish and subscribe](#publish-and-subscribe)

## Requirements

* iOS 15.0+ / macOS 14.0+
* Xcode 14+
* Swift 5+

The TSL iOS SDK contain an external dependencies of PubNub SDK.

## Get keys

You will need the publish and subscribe keys to authenticate your app. Get your keys from the backend.

## Set up your project

You have several options to set up your project using swift package manager.

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

1. Create or open your project inside of Xcode
1. Navigate to File > Swift Packages > Add Package Dependency
1. Search for Talkshoplive and select the swift package owned by tsl, and hit the Next button
1. Use the `Up to Next Major Version` rule and hit the Next button

For more information see Apple's guide on [Adding Package Dependencies to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Configure Talkshoplive SDK

1. Import the module named `Talkshoplive` inside your AppDelegate:

    ```swift
    import UIKit
    import Talkshoplive // <- Here is our Talkshoplive module import.
    ```

1. Create and configure a PubNub object:

    ```swift
    var configuration = TSLIOSSDKConfiguration(
      publishKey: "myPublishKey",
      subscribeKey: "mySubscribeKey",
      uuid: "myUniqueUUID"
    )
    
    
## Run the Tests: 
1. In your Xcode project, navigate to the relatedFile_tests target. After that Click the "Play" button or use the shortcut Cmd + U to build and run the tests.
2. After the tests are run, you can view the results in the Test navigator.
3. Successful tests will be marked with a green checkmark, and failed tests will be marked with a red X. 
4. You can click on each test to see detailed output.


## Support

If you **need help** or have a **general question**, contact <support@talkshoplive.com>.
