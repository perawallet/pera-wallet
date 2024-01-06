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

//   AnnouncementAPIDataController.swift

import Foundation

final class AnnouncementAPIDataController {
    weak var delegate: AnnouncementAPIDataControllerDelegate?
    
    private let api: ALGAPI
    private let session: Session
    
    init(api: ALGAPI, session: Session) {
        self.api = api
        self.session = session
    }
    
    func loadData() {
        guard let deviceId = session.authenticatedUser?.getDeviceId(on: api.network) else {
            return
        }
        
        api.getAnnouncements(AnnouncementFetchDraft(deviceId: deviceId)) { [weak self] response in
            guard let self = self else {
                return
            }
            
            switch response {
            case .failure:
                /// note: Delegate won't called here because we won't show any error on ui side.
                ///  If we support error handling necessary views, delegate will be called with errors
                break
            case .success(let announcementList):
                var announcements = announcementList.results.filter { announcement in
                    !self.session.isAnnouncementHidden(announcement)
                }

                if self.isBackupAnnouncementVisible(of: self.session) {
                    announcements += [Announcement(type: .backup)]
                }
                
                self.delegate?.announcementAPIDataController(
                    self,
                    didFetch: announcements
                )
            }
        }
    }

    func hideAnnouncement(_ announcement: Announcement) {
        session.setAnnouncementHidden(announcement, isHidden: true)
    }

    private func isBackupAnnouncementVisible(of session: Session) -> Bool {
//        let isThereABackupCompleted = !session.backups.isEmpty
        return false
    }
}

protocol AnnouncementAPIDataControllerDelegate: AnyObject {
    func announcementAPIDataController(
        _ dataController: AnnouncementAPIDataController,
        didFetch announcements: [Announcement]
    )
}
