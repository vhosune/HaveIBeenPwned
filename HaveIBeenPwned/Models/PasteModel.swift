//
//  Copyright © 2018 Vincent HO-SUNE. All rights reserved.
//

import Foundation


/// PasteModel for Paste's related API
public final class PasteModel: Decodable, CustomDebugStringConvertible {
    
    /// The paste service the record was retrieved from.
    /// Current values are: Pastebin, Pastie, Slexy, Ghostbin, QuickLeak, JustPaste, AdHocUrl, OptOut
    public let source: String
    
    /// The ID of the paste as it was given at the source service.
    /// Combined with the "Source" attribute, this can be used to resolve the URL of the paste.
    public let identifier: String
    
    /// The title of the paste as observed on the source site.
    /// This may be null and if so will be omitted from the response.
    public let title: String?
    
    /// The date and time (precision to the second) that the paste was posted.
    /// This is taken directly from the paste site when this information is available
    /// but may be null if no date is published.
    public let date: Date?
    
    /// The number of emails that were found when processing the paste.
    /// Emails are extracted by using the regular expression \b+(?!^.{256})[a-zA-Z0-9\.\-_\+]+@[a-zA-Z0-9\.\-_]+\.[a-zA-Z]+\b
    public let emailCount: UInt
    
    
    // MARK: Decodable
    
    private enum CodingKeys: String, CodingKey {
        case source = "Source"
        case identifier = "Id"
        case title = "Title"
        case date = "Date"
        case emailCount = "EmailCount"
    }
    
    /// init from `Decoder`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.source = try container.decode(String.self, forKey: .source)
        self.identifier = try container.decode(String.self, forKey: .identifier)
        self.title = try? container.decode(String.self, forKey: .title)
        
        self.emailCount = try container.decode(UInt.self, forKey: .emailCount)
        
        if let iso8601: String = try? container.decode(String.self, forKey: .date) {
            self.date = SupportTools.datetimeFormatter.date(from: iso8601) ?? Date(timeIntervalSince1970: 0)
        }
        else {
            self.date = nil
        }
    }
    
    // MARK: CustomDebugStringConvertible

    public var debugDescription: String {
        return "<\(Swift.type(of: self)): \(String(describing: self.title)) | \(self.source)>"
    }


}
