# HaveIBeenPwned

[![Language](https://img.shields.io/badge/language-swift-orange)](https://github.com/vhosune/HaveIBeenPwned)
[![Platform](https://img.shields.io/cocoapods/p/HaveIBeenPwned)](https://github.com/vhosune/HaveIBeenPwned)
[![HaveIBeenPwned](https://img.shields.io/badge/api-v3-blue)](https://haveibeenpwned.com/API/v3)
[![GitHub license](https://img.shields.io/github/license/vhosune/HaveIBeenPwned)](https://raw.githubusercontent.com/vhosune/HaveIBeenPwned/master/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/vhosune/HaveIBeenPwned?sort=semver)](https://github.com/vhosune/HaveIBeenPwned/releases)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/HaveIBeenPwned)](https://cocoapods.org/pods/HaveIBeenPwned)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Swift library for [haveibeenpwned.com](https://haveibeenpwned.com) using APIv3

**Notes:** Some API request needs a [paid API key](https://haveibeenpwned.com/API/Key)

## Requirements

- iOS 8.0+ / macOS 10.10+
- Swift 5+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects.

`Podfile`:

```ruby
pod 'HaveIBeenPwned'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

`Cartfile`:

```ogdl
github "vhosune/HaveIBeenPwned"
```

## Quick hands on

- Check if a password has already been pwned in a breach

```swift
    import HaveIBeenPwned

    // init HaveIBeenPwned with its Settings
    let pwned = HaveIBeenPwned(with: HaveIBeenPwned.Settings())

    // create a request
    if let request = pwned.requestSearch(password: "password") {

        // fetch the request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
            // parse the result
            let result = pwned.parseResponse(data, response, error)
                
            // handle the parsed result
            if case .passwords(let ranges) = try? result.get() {
                let count = HaveIBeenPwned.search(for: "password", in: ranges)
                print("has been pwned \(count) times")
            }
        }
            
        task.resume()
    }
```

- Check if a site has been breached

```swift
    let request = pwned.requestBreach(name: "yahoo")
```

- Check if a user account appears in a breach

```swift

    // init HaveIBeenPwned with its Settings and the Api key
    let pwned = HaveIBeenPwned(with: HaveIBeenPwned.Settings(apiKey: "YOUR_API_KEY"))
    let request = pwned.requestBreached(account: "user@example.com")

```



