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
//  Node.swift

import Foundation
import CoreData

@objc(Node)
public final class Node: NSManagedObject {
    @NSManaged public var address: String?
    @NSManaged public var token: String?
    @NSManaged public var name: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var creationDate: Date
}

extension Node {
    static let entityName = "Node"
}

extension Node {
    enum DBKeys: String {
        case address = "address"
        case token = "token"
        case name = "name"
        case isActive = "isActive"
        case creationDate = "creationDate"
    }
}

extension Node: DBStorable { }
