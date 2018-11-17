# HaveIBeenPwned

[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/vhosune/HaveIBeenPwned/blob/master/LICENSE)
[![Cocoapods Compatible](https://img.shields.io/badge/pods-1.0.1-blue.svg)](https://cocoapods.org/pods/HaveIBeenPwned)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Swift library for [haveibeenpwned.com](https://haveibeenpwned.com)

## Quick hands on

- Check if a password has already been pwned in a breach

```swift
import HaveIBeenPwned

let session = HaveIBeenPwned()

try? session.search(password: "password") { result in
    if let pwned = try? result() {
        print("password pwned \(pwned) times.")
    }
}

```

- Check if a site has been breached

```swift
let session = HaveIBeenPwned()

_ = try? session.breach(name: "yahoo", completion: { result in
    do {
        let pwned = try result()
        print("breach \(pwned)")
    }
    catch HaveIBeenPwned.ErrorCode.notFound {
        print("not breached")
    }
    catch {
    }
    
})
```

- Check if a user account appears in a breach

```swift
let session = HaveIBeenPwned()

_ = try? session.breached(account: "user@example.com", completion: { result in
    do {
        let pwned = try result()
        print("breached \(pwned)")
    }
    catch HaveIBeenPwned.ErrorCode.notFound {
        print("not breached")
    }
    catch {
    }
    
})

```

## Requirements

- iOS 8.0+
- Xcode 10.0+
- Swift 4.2+

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

