//
//  Copyright © 2018 Vincent HO-SUNE. All rights reserved.
//

import Foundation
import CommonCrypto


/// support tools for `HaveIBeenPwned`
internal class SupportTools {
    
    /// iso 8901: yyyy-MM-dd'T'HH:mm:ssZZZZZ
    static var datetimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        return formatter
    }()
    
    /// iso 8901: yyyy-MM-dd
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    
    /// returns sha1 of `string` as hexbytes string
    static func sha1(string: String) -> String {

        let data = string.data(using: .utf8)!
        let result = data.withUnsafeBytes {
            return self.sha1(bytes: $0, length: data.count)
        }

        return result
    }

    /// returns sha1 of `bytes` as hexbytes string
    static func sha1(bytes: UnsafePointer<UInt8>, length: Int) -> String {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))

        _ = CC_SHA1(bytes, CC_LONG(length), &digest)
        
        // convert bytes to hex string
        let text = digest.map({ String(format: "%02hhx", $0) }).joined()
        return text
    }

    
}
