//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    public struct Settings {
        
        /// your haveibeenpwned.com api key
        /// - note: get an api key at [https://haveibeenpwzned.com/API/Key](https://haveibeenpwned.com/API/Key)
        /// - note: needed only for queries by email address.
        public var apiKey: String?
        
        public init(apiKey: String? = nil) {
            self.apiKey = apiKey
        }
        
    }
    
}
