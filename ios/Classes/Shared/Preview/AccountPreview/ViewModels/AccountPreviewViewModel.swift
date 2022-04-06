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
//   AccountPreviewViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit

struct AccountPreviewViewModel:
    BindableViewModel,
    Hashable {
    private(set) var address: String?
    private(set) var icon: UIImage?
    private(set) var title: EditText?
    private(set) var subtitle: EditText?
    private(set) var primaryAccessory: EditText?
    private(set) var secondaryAccessory: EditText?
    private(set) var accessoryIcon: UIImage?
    
    init<T>(
        _ model: T
    ) {
        bind(model)
    }
}

extension AccountPreviewViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if var accountPortfolio = model as? AccountPortfolio {
            address = accountPortfolio.account.value.address
            
            accountPortfolio.calculate()
            
            bindIcon(accountPortfolio)
            bindTitle(accountPortfolio)
            bindSubtitle(accountPortfolio)
            bindPrimaryAccessory(accountPortfolio)
            bindSecondaryAccessory(accountPortfolio)
            bindAccessoryIcon(accountPortfolio)

            return
        }
        
        if let account = model as? Account {
            address = account.address
            
            bindIcon(account)
            bindTitle(account)
            bindSubtitle(account)
            bindPrimaryAccessory(account)
            bindSecondaryAccessory(account)
            bindAccessoryIcon(account)
            
            return
        }
        
        if let customAccountPreview = model as? CustomAccountPreview {
            bindIcon(customAccountPreview)
            bindTitle(customAccountPreview)
            bindSubtitle(customAccountPreview)
            bindPrimaryAccessory(customAccountPreview)
            bindSecondaryAccessory(customAccountPreview)
            bindAccessoryIcon(customAccountPreview)
            
            return
        }

        if let iconWithShortAddressDraft = model as? IconWithShortAddressDraft {
            address = iconWithShortAddressDraft.account.address

            bindIcon(iconWithShortAddressDraft)
            bindTitle(iconWithShortAddressDraft)

            return
        }
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ accountPortfolio: AccountPortfolio
    ) {
        bindIcon(accountPortfolio.account.value)
    }
    
    mutating func bindTitle(
        _ accountPortfolio: AccountPortfolio
    ) {
        bindTitle(accountPortfolio.account.value)
    }
    
    mutating func bindSubtitle(
        _ accountPortfolio: AccountPortfolio
    ) {
        if accountPortfolio.valueResult.isFailure {
            subtitle = nil
            return
        }
        
        bindSubtitle(
            numberOfAssets: accountPortfolio.account.value.standardAssets.count,
            numberOfCollectibles: accountPortfolio.account.value.collectibleAssets.count
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ accountPortfolio: AccountPortfolio
    ) {
        if accountPortfolio.valueResult.isFailure {
            primaryAccessory = nil
            return
        }
        
        bindPrimaryAccessory(accountPortfolio.valueResult.abbreviatedUiDescription)
    }
    
    mutating func bindSecondaryAccessory(
        _ accountPortfolio: AccountPortfolio
    ) {
        secondaryAccessory = nil
    }
    
    mutating func bindAccessoryIcon(
        _ accountPortfolio: AccountPortfolio
    ) {
        bindAccessoryIcon(isValid: accountPortfolio.valueResult.isSuccess)
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.image
    }
    
    mutating func bindTitle(
        _ account: Account
    ) {
        bindTitle(account.name)
    }
    
    mutating func bindSubtitle(
        _ account: Account
    ) {
        bindSubtitle(
            numberOfAssets: account.standardAssets.count,
            numberOfCollectibles: account.collectibleAssets.count
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ account: Account
    ) {
        primaryAccessory = nil
    }
    
    mutating func bindSecondaryAccessory(
        _ account: Account
    ) {
        secondaryAccessory = nil
    }
    
    mutating func bindAccessoryIcon(
        _ account: Account
    ) {
        accessoryIcon = nil
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ customAccountPreview: CustomAccountPreview
    ) {
        icon = customAccountPreview.icon
    }
    
    mutating func bindTitle(
        _ customAccountPreview: CustomAccountPreview
    ) {
        bindTitle(customAccountPreview.title)
    }
    
    mutating func bindSubtitle(
        _ customAccountPreview: CustomAccountPreview
    ) {
        bindSubtitle(customAccountPreview.subtitle)
    }
    
    mutating func bindPrimaryAccessory(
        _ customAccountPreview: CustomAccountPreview
    ) {
        bindPrimaryAccessory(customAccountPreview.accessory)
    }
    
    mutating func bindSecondaryAccessory(
        _ customAccountPreview: CustomAccountPreview
    ) {
        secondaryAccessory = nil
    }
    
    mutating func bindAccessoryIcon(
        _ customAccountPreview: CustomAccountPreview
    ) {
        accessoryIcon = nil
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ iconWithShortAddressDraft: IconWithShortAddressDraft
    ) {
        icon = iconWithShortAddressDraft.account.image
    }

    mutating func bindTitle(
        _ iconWithShortAddressDraft: IconWithShortAddressDraft
    ) {
        let account = iconWithShortAddressDraft.account

        let title = account.name.unwrap(
            or: account.address.shortAddressDisplay
        )

        bindTitle(title)
    }
}

extension AccountPreviewViewModel {
    mutating func bindTitle(
        _ aTitle: String?
    ) {
        let font = Fonts.DMSans.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        title = .attributedString(
            (aTitle ?? "title-unknown".localized).attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingMiddle),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
    
    mutating func bindSubtitle(
        numberOfAssets: Int,
        numberOfCollectibles: Int
    ) {
        let numberOfAssetsDescription: String
        let numberOfCollectiblesDescription: String
        /// <todo>
        /// Support singulars/plurals as localization feature
        if numberOfAssets > 0 {
            numberOfAssetsDescription =
                "title-plus-asset-count".localized(params: "\(numberOfAssets + 1)")
        } else {
            numberOfAssetsDescription = "title-plus-asset-singular-count".localized(params: "1")
        }

        var subtitle = numberOfAssetsDescription

        if numberOfCollectibles > 0 {
            if numberOfCollectibles > 1 {
                numberOfCollectiblesDescription = "title-plus-collectible-count".localized(params: "\(numberOfCollectibles)")
            } else {
                numberOfCollectiblesDescription = "title-plus-collectible-singular-count".localized(params: "1")
            }

            subtitle += ", " + numberOfCollectiblesDescription
        }

        bindSubtitle(subtitle)
    }
    
    mutating func bindSubtitle(
        _ aSubtitle: String?
    ) {
        guard let aSubtitle = aSubtitle else {
            subtitle = nil
            return
        }
        
        let font = Fonts.DMSans.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        subtitle = .attributedString(
            aSubtitle.attributed([
                .font(font),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier)
                ])
            ])
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            primaryAccessory = nil
            return
        }
        
        let font = Fonts.DMMono.regular.make(15)
        let lineHeightMultiplier = 1.23
        
        primaryAccessory = .attributedString(
            accessory.attributed([
                .font(font),
                .letterSpacing(-0.3),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.right)
                ])
            ])
        )
    }
    
    mutating func bindSecondaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            secondaryAccessory = nil
            return
        }
        
        let font = Fonts.DMMono.regular.make(13)
        let lineHeightMultiplier = 1.18
        
        secondaryAccessory = .attributedString(
            accessory.attributed([
                .font(font),
                .letterSpacing(-0.3),
                .lineHeightMultiplier(lineHeightMultiplier, font),
                .paragraph([
                    .lineBreakMode(.byTruncatingTail),
                    .lineHeightMultiple(lineHeightMultiplier),
                    .textAlignment(.right)
                ])
            ])
        )
    }
    
    mutating func bindAccessoryIcon(
        isValid: Bool
    ) {
        accessoryIcon = isValid ? nil : "icon-red-warning".uiImage
    }
}

struct CustomAccountPreview {
    var icon: UIImage?
    var title: String?
    var subtitle: String?
    var accessory: String?
    
    init(
        icon: UIImage?,
        title: String?,
        subtitle: String?
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    /// <todo>
    /// We should check & remove `AccountNameViewModel` & `AuthAccountNameViewModel`.
    init(
        _ viewModel: AccountNameViewModel
    ) {
        icon = viewModel.image
        title = viewModel.name
        subtitle = nil
        accessory = nil
    }
    
    init(
        _ viewModel: AuthAccountNameViewModel
    ) {
        icon = viewModel.image
        title = viewModel.address
        subtitle = nil
        accessory = nil
    }

    init(
        _ viewModel: AlgoAccountViewModel
    ) {
        icon = viewModel.image
        title = viewModel.address
        subtitle = nil
        accessory = viewModel.amount
    }
}

struct IconWithShortAddressDraft {
    let account: Account

    init(
        _ account: Account
    ) {
        self.account = account
    }
}
