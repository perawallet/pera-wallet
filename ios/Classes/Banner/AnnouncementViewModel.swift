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
    private(set) var title: String?
    private(set) var subtitle: String?
    private(set) var ctaTitle: String?
    private(set) var isGeneric: Bool = false
    private(set) var ctaUrl: URL?

    init(_ model: Announcement) {
        title = model.title
        subtitle = model.subtitle
        ctaTitle = model.buttonLabel
        isGeneric = model.type == .generic
        ctaUrl = model.buttonUrl.toURL()
    }
}
