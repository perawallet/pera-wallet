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

//   DiscoverSearchListNotFoundViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct DiscoverSearchListNotFoundViewModel: ViewModel {
    private(set) var icon: Image?
    private(set) var title: TextProvider?

    init() {
        bindIcon()
        bindTitle()
    }
}

extension DiscoverSearchListNotFoundViewModel {
    mutating func bindIcon() {
        icon = "icon-info-square".templateImage
    }

    mutating func bindTitle() {
        title = "asset-not-found-title"
            .localized
            .bodyMedium(alignment: .center)
    }
}
