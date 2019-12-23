//
// Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    /// the infered response parsed to objects
    public enum ResponseType {
        case breachedAccount([HaveIBeenPwned.Breach])
        case breachedAccountTruncated([String])
        
        case breaches([HaveIBeenPwned.Breach])
        
        case breach(HaveIBeenPwned.Breach)
        
        case pastes([HaveIBeenPwned.Paste])
        
        case dataClasses([String])
        
        case passwords([HaveIBeenPwned.Range])
    }
    
    /// Check for http errors
    private func checkErrorStatus(_ response: URLResponse?, _ error: Error?) -> Error? {
        guard let httpResponse = response as? HTTPURLResponse else {
            fatalError("debug: there should be a HTTPURLResponse")
        }
        
        // check http response status code
        switch httpResponse.statusCode {
            case 400: return ErrorCode.badRequest
            case 401: return ErrorCode.unauthorised
            case 403: return ErrorCode.forbidden
            case 404: return ErrorCode.notFound
            case 429:
                var retrySeconds: Int = 2
                if let retry = httpResponse.allHeaderFields["Retry-After"] as? String, let seconds = Int(retry) {
                    retrySeconds = seconds
                }
                return ErrorCode.tooManyRequests(retrySeconds)
            case 503: return ErrorCode.unauthorised
            case 200: ()
            default:
                if let error = error {
                    return error
            }
        }
        
        return nil
    }
    
    /// Try to parse endpoint to expected `ResponseType`
    ///
    /// - parameter endpoint: the calle endpoint
    /// - parameter data: the JSON
    ///
    /// - returns: `Result<ResponseType, ErrobrCode>`
    ///
    private func parseEndpoint(_ endpoint: ApiEndPoint, with data: Data) -> Result<ResponseType, Error> {
        switch endpoint {
            case .apiBreach:
                do {
                    let result = try self.parseBreachModel(data: data)
                    return .success(.breach(result))
                } catch {
                    return .failure(ErrorCode.badJSON)
            }
            
            case .apiBreachedAccount:
                // try truncated Breach (default)
                do {
                    let result = try self.parseTruncatedBreachModel(data: data)
                    return .success(.breachedAccountTruncated(result))
                } catch {
                }
                
                // try full Breach
                do {
                    let result = try self.parseBreachModels(data: data)
                    return .success(.breachedAccount(result))
                } catch {
                    
                }
                
                return .failure(ErrorCode.badJSON)
            
            case .apiBreaches:
                do {
                    let result = try self.parseBreachModels(data: data)
                    return .success(.breaches(result))
                } catch {
                    return .failure(ErrorCode.badJSON)
            }
            
            case .apiDataclasses:
                do {
                    let result = try self.parseStrings(data: data)
                    return .success(.dataClasses(result))
                } catch {
                    return .failure(ErrorCode.badJSON)
            }
            
            case .apiPasteAccount:
                do {
                    let result = try self.parsePasteModels(data: data)
                    return .success(.pastes(result))
                } catch {
                    return .failure(ErrorCode.badJSON)
            }
            
            case .apiPwnedPasswordsRange:
                do {
                    let result = try self.parseRangeModels(data: data)
                    return .success(.passwords(result))
                } catch {
                    return .failure(ErrorCode.badJSON)
            }
        }
    }
    
    /// parse the response to `ResponseType`
    ///
    /// - parameter data: `Data` received
    /// - parameter response; `HTTPURLResponse` of the request
    /// - parameter error: `Error` network request error
    ///
    /// - returns: `Result<ResponseType, ErrobrCode>`
    ///
    public func parseResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<ResponseType, Error> {
        
        guard let url = response?.url else {
            fatalError("debug: there should be an URL")
        }
        
        // check http error
        if let errorStatus = self.checkErrorStatus(response, error) {
            return .failure(errorStatus)
        }
        
        guard let data = data else {
            return .failure(ErrorCode.badJSON)
        }
        
        // try to find the response ApiEndPoint
        guard let endpoint = ApiEndPoint.allCases.first(where: { api in
            // note: beware of apiBreaches and apiBreach looks similar if allCases reorders them.
            return url.absoluteString.contains(api.rawValue)
        }) else {
            return .failure(ErrorCode.badJSON)
        }
        
        // try parsing endpoint
        return self.parseEndpoint(endpoint, with: data)
    }
    
}
