# Desk360 Chat iOS SDK

[![Swift Version](https://img.shields.io/badge/Swift-5.2.x-orange.svg)](https://swift.org) [![CocoaPods Compatible](https://img.shields.io/cocoapods/p/Desk360LiveChat.svg?style=flat)](http://cocoapods.org/pods/Desk360LiveChat)   ![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Desk360LiveChat?style=plastic) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

<p align="center">
Desk360 Chat SDK  provides simplicity and usability in one place. With this feature, you can provide live support to your customers directly within your app just by writing a few lines of code.
</p>

## Features

* [x]  Talk to your customers using our panel and make use of our SDK to identify a user and provide contextual support.
* [x] Ability to integrate Chatbots.
* [x] Multi-lingual support: It supports 40+ languages.
* [x] Supports different types of media and file formats.
* [x] Easy to use and integrate, only one line of code!
* [x] Smart Plugs.
* [x] Canned Response.
* [x] Auto-Login.

## Example

The example application is the best way to see `LiveChat` in action. Simply open the `Desk360LiveChat.xcworkspace` and run the `Example` scheme.

## Installation

### CocoaPods

Desk360LiveChat is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod 'Desk360LiveChat'
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate LiveChat into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

You must add your info.plist file.

```
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow the app to access your photos.</string>
```

you can present the live support screen from any view controller like follows.

### Initialization

   ```swift
   let properties = LiveChatProperties(
         appKey: apiKey,
         host: host,
         deviceID: uuid,
         loginCredentials: credentials,
         smartPlug: smartPlug
   )

   Desk360LiveChat.shared.start(using: properties, on: self)
   ```

### Smart Plugs

   ```swift
   let keyValues: SmartPlugType = [
      "key1": 15,
      "key2": true,
      "key3": [1,2,3,4],
      "key4": ["a","b","c"],
      "key5": ["key6": 0]
   ]
   let smartPlug = SmartPlug(keyValues)
   ```

   Pass your Smart Plugs object to the `LiveChatProperties`.

### Auto-Login

   For enabling auto-login pass pre-defined user credentials into the SDK start method..
   ```swift
      var credentials =  Credentials(name: "Test", email: "test@test.com")
   ```

<br>

> If you're using IQKeyboardManager in your project please ignore Desk360LiveChat classes from it by calling:
>

```swift
let viewControllers = LiveChat.shared.viewControllersToBeExcludedFromIQKeyboardManager
viewControllers.forEach {
   IQKeyboardManager.sharedManager().disabledDistanceHandlingClasses.append($0)
   }
```

##  Theme Customization

You should use  [Desk360](https://desk360.com/)  dashboard for appearance configurations.

## License

Desk360LiveChat is released under the MIT license. See  [LICENSE](https://github.com/Teknasyon-Teknoloji/desk360-livechat-ios-sdk/blob/master/LICENSE)  for more information.
