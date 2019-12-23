//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
 
    // MARK: dataclasses

    /// Request all data classes in the system
    /// A "data class" is an attribute of a record compromised in a breach.
    /// For example, many breaches expose data classes such as "Email addresses" and "Passwords".
    ///
    /// - returns: the `URLRequest`
    ///
    public func requestDataClasses() -> URLRequest? {
        guard let url = URL(string: ApiEndPoint.apiDataclasses.rawValue) else {
            return nil
        }
        
        return self.generateRequest(with: url, withApiKey: false)
    }
    
    /// parse JSON array `String`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `String`
    ///
    internal func parseStrings(data: Data) throws -> [String] {
        if let objects = try? JSONSerialization.jsonObject(with: data, options: []), let result = objects as? [String] {
            return result
        }
        
        throw ErrorCode.badRequest
    }

}
