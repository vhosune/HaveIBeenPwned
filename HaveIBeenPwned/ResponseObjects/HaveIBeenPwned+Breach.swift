//
//  Copyright © Vincent HO-SUNE. All rights reserved.
//

import Foundation

extension HaveIBeenPwned {
    
    /// Breach model for Breach related API
    ///
    /// - note: In the future, these attributes may expand without the API being versioned.
    ///
    public struct Breach: Decodable, CustomDebugStringConvertible {
        
        /// A Pascal-cased name representing the breach which is unique across all other breaches.
        /// This value never changes and may be used to name dependent assets (such as images)
        /// but should not be shown directly to end users (see the "Title" attribute instead).
        public let name: String
        
        /// A descriptive title for the breach suitable for displaying to end users.
        /// It's unique across all breaches but individual values may change in the future
        /// (i.e. if another breach occurs against an organisation already in the system).
        /// If a stable value is required to reference the breach, refer to the "Name" attribute instead.
        public let title: String
        
        /// The domain of the primary website the breach occurred on.
        /// This may be used for identifying other assets external systems may have for the site.
        public let domain: String
        
        /// The date (with no time) the breach originally occurred on in ISO 8601 format.
        /// This is not always accurate — frequently breaches are discovered and reported long after the original incident.
        /// Use this attribute as a guide only.
        public let breachDate: Date
        
        /// The date and time (precision to the minute) the breach was added to the system in ISO 8601 format.
        public let addedDate: Date
        
        /// The date and time (precision to the minute) the breach was modified in ISO 8601 format.
        /// This will only differ from the AddedDate attribute if other attributes represented here
        /// are changed or data in the breach itself is changed (i.e. additional data is identified and loaded).
        /// It is always either equal to or greater then the AddedDate attribute, never less than.
        public let modifiedDate: Date
        
        /// The total number of accounts loaded into the system.
        /// This is usually less than the total number reported by the media due to duplication
        /// or other data integrity issues in the source data.
        public let pwnCount: UInt
        
        /// Contains an overview of the breach represented in HTML markup.
        /// The description may include markup such as emphasis and strong tags as well as hyperlinks.
        public let description: String
        
        /// This attribute describes the nature of the data compromised in the breach
        /// and contains an alphabetically ordered string array of impacted data classes.
        public let dataClasses: [String]
        
        /// Indicates that the breach is considered unverified.
        /// An unverified breach may not have been hacked from the indicated website.
        /// An unverified breach is still loaded into HIBP when there's sufficient confidence
        /// that a significant portion of the data is legitimate.
        public let isVerified: Bool
        
        /// Indicates that the breach is considered fabricated.
        /// A fabricated breach is unlikely to have been hacked from the indicated website
        /// and usually contains a large amount of manufactured data.
        /// However, it still contains legitimate email addresses
        /// and asserts that the account owners were compromised in the alleged breach.
        public let isFabricated: Bool
        
        /// Indicates if the breach is considered sensitive.
        /// The public API will not return any accounts for a breach flagged as sensitive.
        public let isSensitive: Bool
        
        /// Indicates if the breach has been retired.
        /// This data has been permanently removed and will not be returned by the API.
        public let isRetired: Bool
        
        /// Indicates if the breach is considered a spam list.
        /// This flag has no impact on any other attributes
        /// but it means that the data has not come as a result of a security compromise.
        public let isSpamList: Bool
        
        /// A URI that specifies where a logo for the breached service can be found. Logos are always in PNG format.
        public let logoPath: URL?
        
        // MARK: Decodable
        
        private enum CodingKeys: String, CodingKey {
            case name = "Name"
            case title = "Title"
            case domain = "Domain"
            case breachDate = "BreachDate"
            case addedDate = "AddedDate"
            case modifiedDate = "ModifiedDate"
            case pwnCount = "PwnCount"
            case description = "Description"
            case dataClasses = "DataClasses"
            case isVerified = "IsVerified"
            case isFabricated = "IsFabricated"
            case isSensitive = "IsSensitive"
            case isRetired = "IsRetired"
            case isSpamList = "IsSpamList"
            case logoPath = "LogoPath"
        }
        
        /// init from `Decoder`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.name = try container.decode(String.self, forKey: .name)
            self.title = try container.decode(String.self, forKey: .title)
            self.domain = try container.decode(String.self, forKey: .domain)
            self.description = try container.decode(String.self, forKey: .description)
            
            self.dataClasses = try container.decode([String].self, forKey: .dataClasses)
            
            self.pwnCount = try container.decode(UInt.self, forKey: .pwnCount)
            
            self.isVerified = try container.decode(Bool.self, forKey: .isVerified)
            self.isFabricated = try container.decode(Bool.self, forKey: .isFabricated)
            self.isSensitive = try container.decode(Bool.self, forKey: .isSensitive)
            self.isRetired = try container.decode(Bool.self, forKey: .isRetired)
            self.isSpamList = try container.decode(Bool.self, forKey: .isSpamList)
            
            self.logoPath = try container.decode(URL.self, forKey: .logoPath)
            
            do {
                let iso8601: String = try container.decode(String.self, forKey: .addedDate)
                self.addedDate = SupportTools.datetimeFormatter.date(from: iso8601) ?? Date(timeIntervalSince1970: 0)
            }
            
            do {
                let iso8601: String = try container.decode(String.self, forKey: .modifiedDate)
                self.modifiedDate = SupportTools.datetimeFormatter.date(from: iso8601) ?? Date(timeIntervalSince1970: 0)
            }
            
            do {
                let iso8601: String = try container.decode(String.self, forKey: .breachDate)
                self.breachDate = SupportTools.dateFormatter.date(from: iso8601) ?? Date(timeIntervalSince1970: 0)
            }
            
        }
        
        // MARK: CustomDebugStringConvertible
        
        public var debugDescription: String {
            return "<\(Swift.type(of: self)): \(self.title) | \(self.domain)>"
        }
        
    }
    
}
