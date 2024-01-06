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

//   AnnouncementViewModel.swift

import Foundation
import MacaroonUIKit

struct AnnouncementViewModel:
    PairedViewModel,
    Hashable {
    let type: AnnouncementType
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var ctaTitle: String?
    private(set) var ctaUrl: URL?

    var shouldDisplayAction: Bool {
        switch type {
        case .backup:
            return true
        case .governance, .generic:
            return ctaUrl != nil && ctaTitle != nil
        }
    }

    init(_ model: Announcement) {
        type = model.type

        switch model.type {
        case .backup:
            configureForBackup()
        case .generic:
            configureForGeneric(model)
        case .governance:
            configureForGovernance(model)
        }
    }

    private mutating func configureForBackup() {
        title = "algorand-secure-backup-banner-title".localized
        subtitle = "algorand-secure-backup-banner-subtitle".localized
        ctaTitle = "algorand-secure-backup-banner-cta-title".localized
        ctaUrl = nil
    }

    private mutating func configureForGovernance(_ announcement: Announcement) {
        title = announcement.title
        subtitle = announcement.subtitle
        ctaTitle = announcement.buttonLabel
        guard let buttonUrl = announcement.buttonUrl else { return }
        ctaUrl = URL(string: buttonUrl)
    }

    private mutating func configureForGeneric(_ announcement: Announcement) {
        title = announcement.title
        subtitle = announcement.subtitle
        ctaTitle = announcement.buttonLabel
        guard let buttonUrl = announcement.buttonUrl else { return }
        ctaUrl = URL(string: buttonUrl)
    }
}
