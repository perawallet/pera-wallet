// Copyright 2023 Pera Wallet, LDA

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//   WalletConnectV2SessionSource.swift

import Foundation

final class WalletConnectV2SessionSource {
    private(set) var sessions: [String: WalletConnectV2SessionEntity]? {
        get {
            return wcSessionList?.wcSessions
        }

        set {
            guard let sessionData = try? JSONEncoder().encode(newValue) else {
                return
            }

            if let wcSession = wcSessionList {
                wcSession.update(
                    entity: WCv2SessionList.entityName,
                    with: [WCv2SessionList.DBKeys.sessions.rawValue: sessionData]
                )
            } else {
                WCv2SessionList.create(
                    entity: WCv2SessionList.entityName,
                    with: [WCv2SessionList.DBKeys.sessions.rawValue: sessionData]
                )
            }

            Cache.wcSessionList = wcSessionList
        }
    }

    private var wcSessionList: WCv2SessionList? {
        get {
            if Cache.wcSessionList == nil {
                guard WCv2SessionList.hasResult(entity: WCv2SessionList.entityName) else {
                    return nil
                }

                let result = WCv2SessionList.fetchAllSyncronous(entity: WCv2SessionList.entityName)

                switch result {
                case .result(let object):
                    if let session = object as? WCv2SessionList {
                        Cache.wcSessionList = session
                        return Cache.wcSessionList
                    }
                case .results(let objects):
                    if let session = objects.first(where: { $0 is WCv2SessionList }) as? WCv2SessionList {
                        Cache.wcSessionList = session
                        return Cache.wcSessionList
                    }
                case .error:
                    return nil
                }
            }

            return Cache.wcSessionList
        }

        set {
            Cache.wcSessionList = newValue
        }
    }

    func addWalletConnectSession(_ session: WalletConnectV2Session) {
        if sessions != nil {
            if sessions?[session.topic] != nil {
                updateWalletConnectSession(session)
            } else {
                self.sessions?[session.topic] = WalletConnectV2SessionEntity(session)
                syncSessions()
            }
        } else {
            sessions = [session.topic: WalletConnectV2SessionEntity(session)]
        }
    }

    func updateWalletConnectSession(_ session: WalletConnectV2Session) {
        _ = sessions?.updateValue(WalletConnectV2SessionEntity(session), forKey: session.topic)
        syncSessions()
    }

    func removeWalletConnectSession(for topic: WalletConnectTopic) {
        _ = sessions?.removeValue(forKey: topic)
        syncSessions()
    }

    func resetAllSessions() {
        wcSessionList = nil
        WCv2SessionList.clear(entity: WCv2SessionList.entityName)
    }

    private func syncSessions() {
        let updatedSessions = sessions
        self.sessions = updatedSessions
    }
}

extension WalletConnectV2SessionSource {
    private enum Cache {
        static var wcSessionList: WCv2SessionList?
    }
}

struct WalletConnectV2SessionEntity: Codable {
    let topic: WalletConnectTopic
    let connectionDate: Date

    init(_ session: WalletConnectV2Session) {
        topic = session.topic
        connectionDate = .init()
    }
}
