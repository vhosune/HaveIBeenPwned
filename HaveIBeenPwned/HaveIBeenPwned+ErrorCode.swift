//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    /// error codes
    public enum ErrorCode: Error {
        /// Bad request
        /// — the account does not comply with an acceptable format (i.e. it's an empty string)
        /// - some bad input
        case badRequest
        
        /// failed to decode JSON, wrong model
        case badJSON
        
        /// Forbidden — no user agent has been specified in the request
        case forbidden

        /// Unauthorised — either no API key was provided or it wasn't valid
        case unauthorised

        /// Not found — the account could not be found and has therefore not been pwned
        case notFound
        
        /// Too many requests — the rate limit has been exceeded
        /// Requests to the breaches and pastes APIs are limited to one per every 1500 milliseconds
        case tooManyRequests(_ retryInSeconds: Int)
        
        /// ervice unavailable — usually returned by Cloudflare if the underlying service is not available
        case serviceUnavailable
    }
    
}
