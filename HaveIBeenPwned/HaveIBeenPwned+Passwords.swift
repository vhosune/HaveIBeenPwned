//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    // MARK: Password by range
    
    /// Request search for `password` in leaks
    ///
    /// - parameter password: password to search
    ///
    /// - returns: the `URLRequest`
    ///
    /// - note: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    public func requestSearch(password: String) -> URLRequest? {
        let sha1 = SupportTools.sha1(string: password)
        return self.requestSearchRange(with: sha1)
    }
    
    /// Request search for `password` in leaks
    ///
    /// - parameter passwordData: password to search as `Data` to allow secure password handling if needed
    ///
    /// - returns: the `URLRequest`
    ///
    /// - note: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    public func requestSearch(with passwordData: Data) -> URLRequest? {
        let sha1 = SupportTools.sha1(data: passwordData)
        return self.requestSearchRange(with: sha1)
    }
    
    /// Request search password sha1 leaks by range
    ///
    /// - parameter sha1: password's SHA1 to search
    ///
    /// - returns: the `URLRequest`
    ///
    /// - note: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    public func requestSearchRange(with sha1: String) -> URLRequest? {
        
        guard let kAnonymous = self.kAnonymity(for: sha1) else {
            return nil
        }
        
        let urlString: String = ApiEndPoint.apiPwnedPasswordsRange.rawValue + "/\(kAnonymous)"
        
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return self.generateRequest(with: url)
    }
    
    /// search the number of times `password` is pwned in the list of `HaveIBeenPwned.Range`
    ///
    /// - parameter password: password in plain text
    /// - parameter ranges: `[HaveIBeenPwned.Range]` with same prefix
    ///
    /// - returns: the number of times sha1 is pwned found, 0 if not found
    ///
    public static func search(for password: String, in ranges: [HaveIBeenPwned.Range]) -> UInt {
        let sha1 = SupportTools.sha1(string: password)
        return HaveIBeenPwned.search(with: sha1, in: ranges)
    }
    
    /// search the number of times password is pwned in the list of `HaveIBeenPwned.Range`
    ///
    /// - parameter passwordData: password as `Data`
    /// - parameter ranges: `[HaveIBeenPwned.Range]` with same prefix
    ///
    /// - returns: the number of times sha1 is pwned found, 0 if not found
    ///
    public static func search(with passwordData: Data, in ranges: [HaveIBeenPwned.Range]) -> UInt {
        let sha1 = SupportTools.sha1(data: passwordData)
        return HaveIBeenPwned.search(with: sha1, in: ranges)
    }
    
    /// search the number of times the password sha1 is pwned in the list of `HaveIBeenPwned.Range`
    ///
    /// - parameter sha1: password SHA1
    /// - parameter ranges: `[HaveIBeenPwned.Range]` with same prefix
    ///
    /// - returns: the number of times sha1 is pwned found, 0 if not found
    ///
    public static func search(with sha1: String, in ranges: [HaveIBeenPwned.Range]) -> UInt {
        let prefixIndex = sha1.index(sha1.startIndex, offsetBy: 5)
        let suffix: String = String(sha1[prefixIndex..<sha1.endIndex]).uppercased()
        
        if let range = ranges.first(where: {
            return $0.suffix == suffix
        }) {
            return range.count
        } else {
            return 0
        }
    }
    
    // MARK: -
    
    /// anonymize `sha1` using k-Anonymity
    ///
    /// - parameter sha1: password sha1
    ///
    /// - returns: then anonymized sha1
    ///
    internal func kAnonymity(for sha1: String) -> String? {
        // k-Anonymity
        let sha1 = sha1.uppercased()
        let prefixIndex = sha1.index(sha1.startIndex, offsetBy: 5)
        let prefix: String = String(sha1[sha1.startIndex..<prefixIndex])
        
        guard let normalized = prefix.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed), (prefix.count == 5) else {
            return nil
        }
        
        return normalized
    }
    
    /// parse `HaveIBeenPwned.Range` list
    ///
    /// - parameter data: some data CSV style 'hash-suffix:pwned-count\r\n'
    ///
    /// - returns: a list of `HaveIBeenPwned.Range`
    ///
    internal func parseRangeModels(data: Data) throws -> [HaveIBeenPwned.Range] {
        guard let string = String(data: data, encoding: .utf8) else {
            throw ErrorCode.badRequest
        }
        
        var result: [HaveIBeenPwned.Range] = []
        
        let lines = string.split(separator: "\r\n")
        lines.forEach { line in
            let components = line.split(separator: ":")
            if (components.count == 2), let count = UInt(components[1]) {
                result.append(HaveIBeenPwned.Range(suffix: String(components[0]).uppercased(), count: count))
            }
        }
        
        return result
    }
    
}
