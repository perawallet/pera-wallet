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

//   AssetQuickActionViewModel.swift

import Foundation
import MacaroonUIKit

final class AssetQuickActionViewModel {
    private(set) var title: EditText?
    private(set) var titleTopPadding: LayoutMetric?
    
    private(set) var accountTypeImage: ImageStyle?

    private(set) var accountName: EditText?

    private(set) var buttonTitleColor: Color?
    private(set) var buttonBackgroundColor: Color?
    private(set) var buttonIcon: Image?
    private(set) var buttonTitle: EditText?

    private(set) var buttonFirstShadow: MacaroonUIKit.Shadow?
    private(set) var buttonSecondShadow: MacaroonUIKit.Shadow?
    private(set) var buttonThirdShadow: MacaroonUIKit.Shadow?

    init(
        asset: Asset,
        type: ActionType
    ) {
        switch type {
        case .optInWithoutAccount:
            bindTitle(
                asset: asset,
                type: type
            )
            bindButton(
                asset: asset,
                type: type
            )
            return
        case .optIn(let account),
                .optOut(let account):
            bindTitle(
                asset: asset,
                type: type
            )
            bindButton(
                asset: asset,
                type: type
            )
            bindAccountTypeImage(account)
            bindAccountName(account)
        }
    }
}

extension AssetQuickActionViewModel {
    private func bindTitle(
        asset: Asset,
        type: ActionType
    ) {
        switch type {
        case .optIn:
            if asset is CollectibleAsset {
                self.title = .attributedString(
                    "asset-quick-action-title-opt-in"
                        .localized
                        .footnoteRegular(lineBreakMode: .byTruncatingTail)
                )
                return
            }

            self.title = .attributedString(
                "asset-quick-action-title-add"
                    .localized
                    .footnoteRegular(lineBreakMode: .byTruncatingTail)
            )
        case .optInWithoutAccount:
            self.titleTopPadding = 26

            if asset is CollectibleAsset {
                self.title = .attributedString(
                    "asset-quick-action-title-add-nft-without-account"
                        .localized
                        .footnoteRegular(lineBreakMode: .byTruncatingTail)
                )
                return
            }

            self.title = .attributedString(
                "asset-quick-action-title-add-asset-without-account"
                    .localized
                    .footnoteRegular(lineBreakMode: .byTruncatingTail)
            )
        case .optOut:
            self.title = .attributedString(
                "asset-quick-action-title-remove"
                    .localized
                    .footnoteRegular(lineBreakMode: .byTruncatingTail)
            )
        }
    }

    private func bindAccountTypeImage(_ account: Account) {
        self.accountTypeImage = [
            .image(account.typeImage),
            .isInteractable(false)
        ]
    }

    private func bindAccountName(_ account: Account) {
        self.accountName = .attributedString(
            account.primaryDisplayName.footnoteRegular(lineBreakMode: .byTruncatingTail)
        )
    }

    func bindButton(
        asset: Asset,
        type: ActionType
    ) {
        switch type {
        case .optIn:
            self.buttonIcon = img("icon-quick-action-plus")
            self.buttonTitleColor = Colors.Button.Primary.text
            self.buttonBackgroundColor = Colors.Button.Primary.background

            if asset is CollectibleAsset {
                self.buttonTitle = .attributedString(
                    "single-transaction-request-opt-in-title"
                        .localized
                        .footnoteMedium(lineBreakMode: .byTruncatingTail)
                )
                return
            }

            self.buttonTitle = .attributedString(
                "asset-quick-action-button-add"
                    .localized
                    .footnoteMedium(lineBreakMode: .byTruncatingTail)
            )
        case .optInWithoutAccount:
            self.buttonIcon = img("icon-quick-action-plus")
            self.buttonTitleColor = Colors.Button.Primary.text
            self.buttonBackgroundColor = Colors.Button.Primary.background

            if asset is CollectibleAsset {
                self.buttonTitle = .attributedString(
                    "single-transaction-request-opt-in-title"
                        .localized
                        .footnoteMedium(lineBreakMode: .byTruncatingTail)
                )
                return
            }

            self.buttonTitle = .attributedString(
                "asset-quick-action-button-add"
                    .localized
                    .footnoteMedium(lineBreakMode: .byTruncatingTail)
            )
        case .optOut:
            self.buttonIcon = img("icon-quick-action-remove")
            self.buttonTitle = .attributedString(
                "title-remove"
                    .localized
                    .footnoteMedium(lineBreakMode: .byTruncatingTail)
            )
            self.buttonTitleColor = Colors.Helpers.negative
            self.buttonBackgroundColor = Colors.Defaults.background

            bindButtonShadows()
        }
    }
}

extension AssetQuickActionViewModel {
    private func bindButtonShadows() {
        self.buttonFirstShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow3.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 0),
            radius: 0,
            spread: 1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.buttonSecondShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow2.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: 0,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
        self.buttonThirdShadow = MacaroonUIKit.Shadow(
            color: Colors.Shadows.Cards.shadow1.uiColor,
            fillColor: Colors.Defaults.background.uiColor,
            opacity: 1,
            offset: (0, 2),
            radius: 4,
            spread: -1,
            cornerRadii: (4, 4),
            corners: .allCorners
        )
    }
}

extension AssetQuickActionViewModel {
    enum ActionType {
        case optIn(with: Account)
        case optInWithoutAccount
        case optOut(from: Account)
    }
}
