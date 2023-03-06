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

//   NavigationPrimaryTitleItemViewModel.swift

import Foundation
import MacaroonUIKit

struct NavigationPrimaryTitleItemViewModel: PrimaryTitleViewModel {
    private(set) var primaryTitle: TextProvider?
    private(set) var primaryTitleAccessory: Image?
    private(set) var secondaryTitle: TextProvider?
    
    init(
        title: String,
        detail: String
    ) {
        bindPrimaryTitle(title)
        bindPrimaryTitleAccessory()
        bindSecondaryTitle(detail)
    }
}

extension NavigationPrimaryTitleItemViewModel {
    mutating func bindPrimaryTitle(_ title: String) {
        primaryTitle = title
            .localized
            .bodyMedium(alignment: .center)
    }
    
    mutating func bindPrimaryTitleAccessory() {
        primaryTitleAccessory = nil
    }
    
    mutating func bindSecondaryTitle(_ detail: String) {
        secondaryTitle = detail
            .localized
            .footnoteRegular(alignment: .center)
    }
}
