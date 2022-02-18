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
//   WCSessionDB.swift

import CoreData

@objc(WCSessionList)
public final class WCSessionList: NSManagedObject {
    @NSManaged public var sessions: Data?

    var wcSessions: [String: WCSession]? {
        guard let data = sessions else {
            return nil
        }
        return try? JSONDecoder().decode([String: WCSession].self, from: data)
    }
}

extension WCSessionList {
    enum DBKeys: String {
        case sessions = "sessions"
    }
}

extension WCSessionList {
    static let entityName = "WCSessionList"
}

extension WCSessionList: DBStorable { }
