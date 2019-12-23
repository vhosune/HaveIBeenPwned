//
//  Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    /// k-Anonymity hash suffix with a count of how many times it appears in the data set.
    public struct Range: CustomDebugStringConvertible {
        
        /// SHA1 hash suffix [5-40]
        public let suffix: String
        
        /// suffix's prevalence counts
        public let count: UInt
        
        /// init with values
        /// - parameter suffix: SHA1 suffix
        /// - parameter count: hash found count
        public init(suffix: String, count: UInt) {
            self.suffix = suffix
            self.count = count
        }
        
        // MARK: CustomDebugStringConvertible
        
        public var debugDescription: String {
            return "<\(Swift.type(of: self)): \(self.suffix) [\(self.count)]>"
        }
        
    }
    
}
