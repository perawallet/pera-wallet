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
//  SettingsDetailViewModel.swift

import Foundation
import UIKit
import MacaroonUIKit

struct SettingsDetailViewModel:
    PrimaryTitleViewModel,
    Hashable {
    private(set) var primaryTitleAccessory: MacaroonUIKit.Image?

    private(set) var image: ImageProvider?
    private(set) var primaryTitle: TextProvider?
    private(set) var secondaryTitle: TextProvider?

    init(settingsItem: Settings) {
        bindImage(settingsItem: settingsItem)
        bindPrimaryTitle(settingsItem: settingsItem)
        bindSecondaryTitle(settingsItem: settingsItem)
    }
}

extension SettingsDetailViewModel {
    private mutating func bindImage(settingsItem: Settings) {
        image = settingsItem.image
    }

    private mutating func bindPrimaryTitle(settingsItem: Settings) {
        primaryTitle = settingsItem.name.bodyRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindSecondaryTitle(settingsItem: Settings) {
        secondaryTitle = settingsItem.subtitle?.footnoteRegular(lineBreakMode: .byTruncatingTail)
    }
}
