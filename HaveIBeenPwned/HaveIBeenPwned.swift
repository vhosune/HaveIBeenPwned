//
//  Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

/// Assess if a password have been compromised or "pwned" in a data breach. Get information about breaches. [https://haveibeenpwned.com/](https://haveibeenpwned.com/)
///
/// [License](https://haveibeenpwned.com/API/v3#License)
///
public struct HaveIBeenPwned {
    
    internal let settings: HaveIBeenPwned.Settings
    
    public init(with settings: HaveIBeenPwned.Settings) {
        self.settings = settings
    }
    
    internal enum ApiEndPoint: String, CaseIterable {
        case apiBreachedAccount = "https://haveibeenpwned.com/api/v3/breachedaccount"
        case apiBreaches = "https://haveibeenpwned.com/api/v3/breaches"
        case apiBreach = "https://haveibeenpwned.com/api/v3/breach"
        
        case apiDataclasses = "https://haveibeenpwned.com/api/v3/dataclasses"
        
        case apiPasteAccount = "https://haveibeenpwned.com/api/v3/pasteaccount"
        
        case apiPwnedPasswordsRange = "https://api.pwnedpasswords.com/range"
    }
    
    /// generate `URLRequest` from `url`, adds custom headers
    ///
    /// - parameter url: `URL` to generate a request with.
    ///
    /// - returns: `URLRequest` ready to send
    ///
    internal func generateRequest(with url: URL, withApiKey needApiKey: Bool = false) -> URLRequest {
        var request = URLRequest(url: url)
                
        if needApiKey {
            if let apiKey = self.settings.apiKey {
                request.addValue(apiKey, forHTTPHeaderField: "hibp-api-key")
            } else {
                assertionFailure("error: apiKey mandatory for this api endpoint.")
            }
        }
        
        return request
    }

}
