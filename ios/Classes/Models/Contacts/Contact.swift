// Copyright 2022 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  Contact.swift

import MagpieCore
import CoreData

@objc(Contact)
public final class Contact: NSManagedObject, Codable {
    @NSManaged public var identifier: String?
    @NSManaged public var address: String?
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    
    public required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Contact", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decodeIfPresent(String.self, forKey: .identifier)
        self.address = try container.decodeIfPresent(String.self, forKey: .address)
        self.image = try container.decodeIfPresent(Data.self, forKey: .image)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(address, forKey: .address)
        try container.encode(image, forKey: .image)
        try container.encode(name, forKey: .name)
    }
    
    func encoded() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}

extension Contact {
    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case address = "address"
        case image = "image"
        case name = "name"
    }
}

extension Contact {
    static let entityName = "Contact"
}

extension Contact: DBStorable { }
