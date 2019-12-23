//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    // MARK: Paste
    
    /// Request for getting all pastes for an account
    ///
    /// - parameter email: account email
    ///
    /// - returns: the `URLRequest`
    ///
    public func requestPastes(for email: String) -> URLRequest? {
        guard let normalized = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        var components = URLComponents(string: ApiEndPoint.apiPasteAccount.rawValue)
        components?.path += "/" + normalized
        
        guard let url = components?.url else {
            return nil
        }
        
        return self.generateRequest(with: url, withApiKey: true)
    }
    
    /// parse `HaveIBeenPwned.Paste` list
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `HaveIBeenPwned.Paste`
    ///
    internal func parsePasteModels(data: Data) throws -> [HaveIBeenPwned.Paste] {
        return try JSONDecoder().decode([HaveIBeenPwned.Paste].self, from: data)
    }

}
