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

//   WCSessionStatusSecondaryListItemViewModel.swift

import Foundation
import MacaroonUIKit

struct WCSessionStatusSecondaryListItemViewModel: SecondaryListItemViewModel {
    private(set) var title: TextProvider?
    private(set) var accessory: SecondaryListItemValueViewModel?
    private(set) var isInteractable: Bool = true

    init(_ status: WCSessionStatus) {
        bindTitle()
        bindAccessory(status)

        isInteractable = status.isIdle
    }
}

extension WCSessionStatusSecondaryListItemViewModel {
    private mutating func bindTitle() {
        title =
            "wc-session-status"
                .localized
                .footnoteRegular(lineBreakMode: .byTruncatingTail)
    }

    private mutating func bindAccessory(_ status: WCSessionStatus) {
        accessory = WCSessionStatusSecondaryListItemValueViewModel(status)
    }
}

fileprivate struct WCSessionStatusSecondaryListItemValueViewModel: SecondaryListItemValueViewModel {
    private(set) var icon: ImageStyle?
    private(set) var title: TextProvider?

    init(_ status: WCSessionStatus) {
        bindTitle(status)
    }
}

extension WCSessionStatusSecondaryListItemValueViewModel {
    private mutating func bindTitle(_ status: WCSessionStatus) {
        switch status {
        case .idle:
            icon = nil
            title = getIdleTitle()
        case .pinging(let progress):
            icon = nil
            title = getPingingTitle(progress)
        case .active:
            icon = getActiveIcon()
            title = getActiveTitle()
        case .failed:
            icon = getFailedIcon()
            title = getFailedTitle()
        }
    }

    private func getIdleTitle() -> TextProvider {
        let aTitle = "wc-session-check-status".localized
        var attributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.positive))
        return aTitle.attributed(attributes)
    }

    private func getPingingTitle(_ progress: ALGProgress) -> TextProvider {
        let dotText = String(repeating: ".", count: progress.currentUnitCount)
        let text = "tite-pinging".localized  + dotText

        var attributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Text.gray))
        return text.attributed(attributes)
    }

    private func getActiveIcon() -> ImageStyle {
        return [
            .image("List/Accessories/check".templateImage),
            .contentMode(.left),
            .tintColor(Colors.Helpers.positive)
        ]
    }

    private func getActiveTitle() -> TextProvider {
        let aTitle = "title-active".localized
        var attributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.positive))
        return aTitle.attributed(attributes)
    }

    private func getFailedIcon() -> ImageStyle {
        return [
            .image("icon-close-20".templateImage),
            .contentMode(.left),
            .tintColor(Colors.Helpers.negative)
        ]
    }

    private func getFailedTitle() -> TextProvider {
        let aTitle = "transaction-detail-failed".localized
        var attributes = Typography.footnoteMediumAttributes(lineBreakMode: .byTruncatingTail)
        attributes.insert(.textColor(Colors.Helpers.negative))
        return aTitle.attributed(attributes)
    }
}

extension WCSessionStatusSecondaryListItemValueViewModel {
    mutating func bindPingingTitle(_ progress: ALGProgress) {
        title = getPingingTitle(progress)
    }
}
