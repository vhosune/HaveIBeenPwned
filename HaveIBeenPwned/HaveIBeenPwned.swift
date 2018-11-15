//
//  Copyright © 2018 Vincent HO-SUNE. All rights reserved.
//

import Foundation


/// Assess if a password have been compromised or "pwned" in a data breach.
/// Get information about breaches
///
/// https://haveibeenpwned.com/
///
/// https://haveibeenpwned.com/API/v2#License
///
public final class HaveIBeenPwned {
    
    private let session: URLSession
    
    public init() {
        self.session = URLSession(configuration: .default)
    }
    
    /// error codes
    public enum ErrorCode: Error {
        /// Bad request
        /// — the account does not comply with an acceptable format (i.e. it's an empty string)
        /// - some bad input
        case badRequest
        
        /// Forbidden — no user agent has been specified in the request
        case forbidden
        
        /// Not found — the account could not be found and has therefore not been pwned
        case notFound
        
        /// Content Negotiation failed (api version deprecated?)
        case notAcceptable
        
        /// Too many requests — the rate limit has been exceeded
        /// Requests to the breaches and pastes APIs are limited to one per every 1500 milliseconds
        case tooManyRequests(_ retryInSeconds: Int)
    }
    
    /// api version
    public static let version: Int = 2
    
    /// `Accept` content negotiation
    public static let contentNegotiation = "application/vnd.haveibeenpwned.v\(HaveIBeenPwned.version)+json"
    
    /// user custom user agent
    public var userAgent: String = "HaveIBeenPwned Swift"
    
    /// base api root path
    private var apiRootPath: String = "https://haveibeenpwned.com/api"
    
    
    // MARK:- Breach
    
    // MARK: Breached Account
    
    fileprivate let apiBreachedAccount: String = "/breachedaccount"
    
    /// optional parameters for `breached(account:)`
    public enum BreachedAccountParameters {
        
        /// Filters the result set to only breaches against the domain specified.
        /// It is possible that one site (and consequently domain), is compromised on multiple occasions.
        case domain(String)
        
        /// Returns breaches that have been flagged as "unverified".
        /// By default, only verified breaches are returned web performing a search.
        case includeUnverified
        
        /// convert enum to `URLQueryItem`
        fileprivate func queryItem() -> URLQueryItem? {
            switch self {
            case .includeUnverified:
                return URLQueryItem(name: "includeUnverified", value: "\(true)")
            case .domain(let value):
                return URLQueryItem(name: "domain", value: value)
            }
        }
        
    }
    
    /// Getting all breaches for an account
    ///
    /// - parameter account: the account name to check (either a name or email)
    /// - parameter parameters: additional request options
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func breached(account: String, parameters: [BreachedAccountParameters]? = nil, completion completionHandler: @escaping (() throws -> [BreachModel]) -> Swift.Void) throws -> URLSessionTask {
        guard let normalized = account.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw ErrorCode.badRequest
        }
        
        let urlString: String = self.apiRootPath + self.apiBreachedAccount + "/" + normalized
        
        var components = URLComponents(string: urlString)
        components?.queryItems = parameters?.compactMap({ $0.queryItem() })
        
        guard let url = components?.url else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parseBreachModels, completion: completionHandler)
    }
    
    /// Getting all breaches for an account (truncated to only names)
    ///
    /// - parameter account: the account name to check (either a name or email)
    /// - parameter parameters: additional request options
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func truncatedBreached(account: String, parameters: [BreachedAccountParameters]? = nil, completion completionHandler: @escaping (() throws -> [String]) -> Swift.Void) throws -> URLSessionTask {
        guard let normalized = account.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw ErrorCode.badRequest
        }
        
        let urlString: String = self.apiRootPath + self.apiBreachedAccount + "/" + normalized
        
        var components = URLComponents(string: urlString)
        
        // custom because not the same result
        var queries: [URLQueryItem] = [URLQueryItem(name: "truncateResponse", value: "\(true)")]
        
        if let paramQueries: [URLQueryItem] = parameters?.compactMap({ $0.queryItem() }) {
            queries.append(contentsOf: paramQueries)
        }
        
        components?.queryItems = queries
        
        guard let url = components?.url else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parseTruncatedBreachModel, completion: completionHandler)
    }
    
    // MARK: Breaches
    
    fileprivate let apiBreaches: String = "/breaches"
    
    /// optional parameters for `breaches`
    public enum BreachesParameters {
        /// Filters the result set to only breaches against the domain specified.
        /// It is possible that one site (and consequently domain), is compromised on multiple occasions.
        case domain(String)
        
        /// convert enum to `URLQueryItem`
        fileprivate func queryItem() -> URLQueryItem? {
            switch self {
            case .domain(let value):
                return URLQueryItem(name: "domain", value: value)
            }
        }
    }
    
    /// Getting all breached sites in the system
    ///
    /// - parameter parameters: additional request options
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func breaches(parameters: [BreachesParameters]? = nil, completion completionHandler: @escaping (() throws -> [BreachModel]) -> Swift.Void) throws -> URLSessionTask {
        let urlString: String = self.apiRootPath + self.apiBreaches
        
        var components = URLComponents(string: urlString)
        components?.queryItems = parameters?.compactMap({$0.queryItem()})
        
        guard let url = components?.url else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parseBreachModels, completion: completionHandler)
    }
    
    // MARK: Breach
    
    fileprivate let apiBreach: String = "/breach"
    
    /// Getting a single breached site
    ///
    /// - parameter name: name a company/site name (not domain)
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func breach(name: String, completion completionHandler: @escaping (() throws -> BreachModel) -> Swift.Void) throws -> URLSessionTask {
        guard let normalized = name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw ErrorCode.badRequest
        }
        
        let urlString: String = self.apiRootPath + self.apiBreach + "/" + normalized
        
        guard let url = URL(string: urlString) else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parseBreachModel, completion: completionHandler)
    }
    
    
    // MARK:- Paste Source
    
    // MARK: Paste
    fileprivate let apiPasteAccount: String = "/pasteaccount"
    
    /// Getting all pastes for an account
    ///
    /// - parameter email: account email
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func pastes(for email: String, completion completionHandler: @escaping (() throws -> [PasteModel]) -> Swift.Void) throws -> URLSessionTask {
        guard let normalized = email.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw ErrorCode.badRequest
        }
        
        let urlString: String = self.apiRootPath + self.apiPasteAccount + "/" + normalized
        
        guard let url = URL(string: urlString) else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parsePasteModels, completion: completionHandler)
    }
    
    // MARK:- Passwords pwned
    
    // MARK: Password by range
    
    fileprivate let apiRange: String = "https://api.pwnedpasswords.com/range"
    
    /// search the number of times sha1 is pwned in the list result of `apiRange`
    ///
    /// - parameter sha1: password SHA1
    /// - parameter ranges: `[RangeModel]` with same prefix
    ///
    /// - returns: the number of times sha1 is pwned found, 0 if not found
    ///
    fileprivate func search(for sha1: String, in ranges: [RangeModel]) -> UInt {
        let prefixIndex = sha1.index(sha1.startIndex, offsetBy: 5)
        let suffix: String = String(sha1[prefixIndex..<sha1.endIndex])
        
        if let range = ranges.first(where: {
            return $0.suffix == suffix
        }) {
            return range.count
        }
        else {
            return 0
        }
    }
    
    /// Search for `password` in leaks
    ///
    /// - parameter password: password to search
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    /// NOTES: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    @discardableResult
    public func search(password: String, completion completionHandler: @escaping (() throws -> UInt) -> Swift.Void) throws -> URLSessionTask {
        let sha1 = SupportTools.sha1(string: password)
        return try self.searchRange(with: sha1, completion: completionHandler)
    }

    /// Search for `password` in leaks
    ///
    /// - parameter passwordBytes: password to search as `UnsafePointer<UInt8>` to allow secure password handling if needed
    /// - parameter passwordBytesLength: `UnsafePointer<UInt8>`'s length
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    /// NOTES: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    @discardableResult
    public func search(with passwordBytes: UnsafePointer<UInt8>, length passwordBytesLength: Int, completion completionHandler: @escaping (() throws -> UInt) -> Swift.Void) throws -> URLSessionTask {
        let sha1 = SupportTools.sha1(bytes: passwordBytes, length: passwordBytesLength)
        return try self.searchRange(with: sha1, completion: completionHandler)
    }

    /// Searching password sha1 leaks by range
    ///
    /// - parameter sha1: password's SHA1 to search
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    /// NOTES: password will not be sent as is,
    /// A k-Anonymity model that allows a password to be searched for by partial hash is used.
    /// (only the first 5 characters of `password` SHA-1 password hash is passed to the API)
    ///
    @discardableResult
    public func searchRange(with sha1: String, completion completionHandler: @escaping (() throws -> UInt) -> Swift.Void) throws -> URLSessionTask {
        
        let sha1 = sha1.uppercased()
        let prefixIndex = sha1.index(sha1.startIndex, offsetBy: 5)
        let prefix: String = String(sha1[sha1.startIndex..<prefixIndex])
        
        guard let normalized = prefix.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed), (prefix.count == 5) else {
            throw ErrorCode.badRequest
        }
        
        let urlString: String = self.apiRange + "/\(normalized)"
        
        guard let url = URL(string: urlString) else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        
        let processResult: (() throws -> [RangeModel]) -> Swift.Void = { result in
            // process raw result to user friendly result
            do {
                let values = try result()
                let count = self.search(for: sha1, in: values)
                completionHandler( { return count })
            }
            catch let error {
                completionHandler( { throw error })
            }
        }
        
        return self.sendRequest(request, parseResult: self.parseRangeModels, completion: processResult)
    }
    
    // MARK:- Other
    
    // MARK: dataclasses
    fileprivate let apiDataclasses: String = "/dataclasses"
    
    /// Getting all data classes in the system
    /// A "data class" is an attribute of a record compromised in a breach.
    /// For example, many breaches expose data classes such as "Email addresses" and "Passwords".
    ///
    /// - parameter completion: completion closure with a throwing function parameter, can throw `ErrorCode`
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    @discardableResult
    public func dataClasses(completion completionHandler: @escaping (() throws -> [String]) -> Swift.Void) throws -> URLSessionTask{
        let urlString: String = self.apiRootPath + self.apiDataclasses
        
        guard let url = URL(string: urlString) else {
            throw ErrorCode.badRequest
        }
        
        let request = self.generateRequest(with: url)
        return self.sendRequest(request, parseResult: self.parseStrings, completion: completionHandler)
    }
    
    // MARK:- Internal Common
    
    /// generate `URLRequest` from `url`, adds custom headers
    ///
    /// - parameter url: `URL` to generate a request with.
    ///
    /// - returns: `URLRequest` ready to send
    ///
    fileprivate func generateRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue(HaveIBeenPwned.contentNegotiation, forHTTPHeaderField: "Accept")
        request.addValue(self.userAgent, forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    /// send `URLRequest`
    ///
    /// - parameter request: `URLRequest` to send
    /// - parameter parseResultHandler: function to parse the request's response
    /// - parameter completionHandler: closure to callback after parsing result
    ///
    /// - returns: the `URLSessionTask` for cancellation
    ///
    fileprivate func sendRequest<T>(_ request: URLRequest, parseResult parseResultHandler: @escaping (Data) throws -> T, completion completionHandler: @escaping (() throws -> T) -> Swift.Void) -> URLSessionTask {
        
        let task = self.session.dataTask(with: request) { [weak self] (data, response, error) in
            self?.processRequest(data: data, response: response as? HTTPURLResponse, error: error, parseResult: parseResultHandler, completion: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    /// process request result
    ///
    /// - parameter data: request's response `Data`
    /// - parameter response: request's `HTTPURLResponse`
    /// - parameter error: request's `Error`
    /// - parameter parseResultHandler: function to parse `data`
    /// - parameter completionHandler: closure to callback on completion
    ///
    fileprivate func processRequest<T>(data: Data?, response: HTTPURLResponse?, error: Error?,
                                       parseResult parseResultHandler: (Data) throws -> T,
                                       completion completionHandler: (() throws -> T) -> Swift.Void) {
        
        if let response = response {
            switch(response.statusCode) {
            case 400: completionHandler({ throw ErrorCode.badRequest })
            case 403: completionHandler({ throw ErrorCode.forbidden })
            case 404: completionHandler({ throw ErrorCode.notFound })
            case 406: completionHandler({ throw ErrorCode.notAcceptable })
            case 429:
                var retrySeconds: Int = 2
                if let retry = response.allHeaderFields["Retry-After"] as? String, let seconds = Int(retry) {
                    retrySeconds = seconds
                }
                
                completionHandler({ throw ErrorCode.tooManyRequests(retrySeconds) })
            case 200: ()
            default:
                if let error = error {
                    completionHandler({ throw error })
                }
            }
        }
        
        if let data = data {
            do {
                let objects = try parseResultHandler(data)
                completionHandler({ objects })
            }
            catch let error {
                completionHandler({ throw error })
            }
        }
    }
    
    // MARK: Parsing Models
    
    /// parse `BreachModel`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a `BreachModel`
    ///
    fileprivate func parseBreachModel(data: Data) throws -> BreachModel {
        return try JSONDecoder().decode(BreachModel.self, from: data)
    }
    
    /// parse `BreachModel` list
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `BreachModel`
    ///
    fileprivate func parseBreachModels(data: Data) throws -> [BreachModel] {
        return try JSONDecoder().decode([BreachModel].self, from: data)
    }
    
    /// parse truncated `BreachModel` to `[String]`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `String`
    ///
    fileprivate func parseTruncatedBreachModel(data: Data) throws -> [String] {
        
        if let objects = try? JSONSerialization.jsonObject(with: data, options: []) {
            guard let list = objects as? [[String: String]] else {
                throw ErrorCode.badRequest
            }
            
            let result: [String] = list.compactMap({ dico in
                return dico["Name"]
            })
            
            return result
        }
        
        throw ErrorCode.badRequest
    }
    
    /// parse JSON array `String`
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `String`
    ///
    fileprivate func parseStrings(data: Data) throws -> [String] {
        if let objects = try? JSONSerialization.jsonObject(with: data, options: []), let result = objects as? [String] {
            return result
        }
        
        throw ErrorCode.badRequest
    }
    
    /// parse `PasteModel` list
    ///
    /// - parameter data: JSON data
    ///
    /// - returns: a list of `PasteModel`
    ///
    fileprivate func parsePasteModels(data: Data) throws -> [PasteModel] {
        return try JSONDecoder().decode([PasteModel].self, from: data)
    }
    
    /// parse `RangeModel` list
    ///
    /// - parameter data: some data CSV style 'hash-suffix:pwned-count\r\n'
    ///
    /// - returns: a list of `RangeModel`
    ///
    fileprivate func parseRangeModels(data: Data) throws -> [RangeModel] {
        guard let string = String(data: data, encoding: .utf8) else {
            throw ErrorCode.badRequest
        }

        var result: [RangeModel] = []

        let lines = string.split(separator: "\r\n")
        lines.forEach { line in
            let components = line.split(separator: ":")
            if (components.count == 2), let count = UInt(components[1]) {
                result.append(RangeModel(suffix: String(components[0]), count: count))
            }
        }
        
        return result
    }
    
    
}
