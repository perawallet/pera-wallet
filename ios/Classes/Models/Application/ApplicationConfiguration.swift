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
//  ApplicationConfiguration.swift

import Foundation
import CoreData

@objc(ApplicationConfiguration)
public final class ApplicationConfiguration: NSManagedObject {
    @NSManaged public var password: String?
    @NSManaged public var authenticatedUserData: Data?
    @NSManaged public var isDefaultNodeActive: Bool
    
    func authenticatedUser() -> User? {
        guard let data = authenticatedUserData else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }
}

extension ApplicationConfiguration {
    enum DBKeys: String {
        case password = "password"
        case userData = "authenticatedUserData"
        case isDefaultNodeActive = "isDefaultNodeActive"
    }
}

extension ApplicationConfiguration {
    static let entityName = "ApplicationConfiguration"
}

extension ApplicationConfiguration: DBStorable { }
