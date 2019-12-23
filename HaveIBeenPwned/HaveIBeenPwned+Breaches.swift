//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    // MARK: Breached Account
    
    /// optional parameters for `requestBreached(account:withParameters:)`
    public enum BreachedAccountParameters {
        
        /// Filters the result set to only breaches against the domain specified.
        /// It is possible that one site (and consequently domain), is compromised on multiple occasions.
        case domain(String)
        
        /// Returns breaches that have been flagged as "unverified".
        /// By default, both verified and unverified breaches are returned when performing a search.
        case includeUnverified(Bool)
        
        /// Returns the full breach model or a truncated to names only list.
        /// By default, only the name of the breach is returned rather than the complete breach data
        case truncateResponse(Bool)
        
        /// convert enum to `URLQueryItem`
        internal func queryItem() -> URLQueryItem? {
            switch self {
                case .includeUnverified(let value):
                    return URLQueryItem(name: "includeUnverified", value: "\(value)")
                case .domain(let value):
                    return URLQueryItem(name: "domain", value: value)
                case .truncateResponse(let value):
                    return URLQueryItem(name: "truncateResponse", value: "\(value)")
            }
        }
    }
    
    /// Request for getting all breaches for an account
    ///
    /// - parameter account: the account name to check (either a name or email)
    /// - parameter parameters: additional request options
    ///
    /// - returns: the `URLRequest`
    ///
    public func requestBreached(account: String, withParameters parameters: [BreachedAccountParameters]? = nil) -> URLRequest? {
        
        guard let normalized = account.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        var components = URLComponents(string: ApiEndPoint.apiBreachedAccount.rawValue)
        components?.queryItems = parameters?.compactMap({ $0.queryItem() })
        components?.path += "/" + normalized
        
        guard let url = components?.url else {
            return nil
        }
        
        return self.generateRequest(with: url, withApiKey: true)
    }
    
    // MARK: Breaches
    
    /// optional parameters for `breaches`
    public enum BreachesParameters {
        /// Filters the result set to only breaches against the domain specified.
        /// It is possible that one site (and consequently domain), is compromised on multiple occasions.
        case domain(String)
        
        /// convert enum to `URLQueryItem`
        internal func queryItem() -> URLQueryItem? {
            switch self {
                case .domain(let value):
                    return URLQueryItem(name: "domain", value: value)
            }
        }
    }
    
    /// Request for getting all breached sites in the system
    ///
    /// - parameter parameters: additional request options
    ///
    /// - returns: the `URLRequest`
    ///
    public func requestBreaches(withParameters parameters: [BreachesParameters]? = nil) -> URLRequest? {
        var components = URLComponents(string: ApiEndPoint.apiBreaches.rawValue)
        components?.queryItems = parameters?.compactMap({ $0.queryItem() })
        
        guard let url = components?.url else {
            return nil
        }
        
        return self.generateRequest(with: url, withApiKey: false)
    }
    
    // MARK: Breach
    
    /// Request for getting a single breached site
    ///
    /// - parameter name: name a company/site name (not domain)
    ///
    /// - returns: the `URLRequest`
    ///
    public func requestBreach(name: String) -> URLRequest? {
        guard let normalized = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        var components = URLComponents(string: ApiEndPoint.apiBreach.rawValue)
        components?.path += "/" + normalized
        
        guard let url = components?.url else {
            return nil
        }
        
        return self.generateRequest(with: url, withApiKey: false)
    }
    
    // MARK: -
    
    /// parse to `HaveIBeenPwned.Breach`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a `HaveIBeenPwned.Breach`
    ///
    internal func parseBreachModel(data: Data) throws -> HaveIBeenPwned.Breach {
        return try JSONDecoder().decode(HaveIBeenPwned.Breach.self, from: data)
    }
    
    /// parse to `HaveIBeenPwned.Breach` list
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `HaveIBeenPwned.Breach`
    ///
    internal func parseBreachModels(data: Data) throws -> [HaveIBeenPwned.Breach] {
        return try JSONDecoder().decode([HaveIBeenPwned.Breach].self, from: data)
    }
    
    /// parse truncated breach to `[String]`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `String`
    ///
    internal func parseTruncatedBreachModel(data: Data) throws -> [String] {
        
        if let objects = try? JSONSerialization.jsonObject(with: data, options: []), let list = objects as? [[String: String]] {
            let result: [String] = list.compactMap({ dico in
                return dico["Name"]
            })
            return result
        }
        
        throw ErrorCode.badJSON
    }
    
}
