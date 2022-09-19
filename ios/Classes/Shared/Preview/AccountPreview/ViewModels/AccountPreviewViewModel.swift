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
import MacaroonURLImage

struct AccountPreviewViewModel:
    PortfolioViewModel,
    BindableViewModel,
    Hashable {

    private(set) var address: String?
    private(set) var icon: ImageSource?
    private(set) var namePreviewViewModel: AccountNamePreviewViewModel?
    private(set) var primaryAccessory: EditText?
    private(set) var secondaryAccessory: EditText?
    private(set) var accessoryIcon: UIImage?

    private(set) var currencyFormatter: CurrencyFormatter?

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
        if let accountPortfolioItem = model as? AccountPortfolioItem {
            address = accountPortfolioItem.accountValue.value.address
            currencyFormatter = accountPortfolioItem.currencyFormatter

            bindIcon(accountPortfolioItem)
            bindNamePreviewViewModel(accountPortfolioItem)
            bindPrimaryAccessory(accountPortfolioItem)
            bindSecondaryAccessory(accountPortfolioItem)
            bindAccessoryIcon(accountPortfolioItem)

            return
        }
        
        if let account = model as? Account {
            address = account.address
            
            bindIcon(account)
            bindNamePreviewViewModel(account)
            bindPrimaryAccessory(account)
            bindSecondaryAccessory(account)
            bindAccessoryIcon(account)
            
            return
        }
        
        if let customAccountPreview = model as? CustomAccountPreview {
            address = customAccountPreview.address

            bindIcon(customAccountPreview)
            bindNamePreviewViewModel(customAccountPreview)
            bindPrimaryAccessory(customAccountPreview)
            bindSecondaryAccessory(customAccountPreview)
            bindAccessoryIcon(customAccountPreview)
            
            return
        }

        if let accountOrderingDraft = model as? AccountOrderingDraft {
            address = accountOrderingDraft.account.address

            bindIcon(accountOrderingDraft)
            bindNamePreviewViewModel(accountOrderingDraft)
            bindAccessoryIcon(accountOrderingDraft)
        }

        if let iconWithShortAddressDraft = model as? IconWithShortAddressDraft {
            address = iconWithShortAddressDraft.account.address

            bindIcon(iconWithShortAddressDraft)
            bindNamePreviewViewModel(iconWithShortAddressDraft)

            return
        }

        if let nameServiceAccountPreview = model as? NameServiceAccountPreview {
            address = nameServiceAccountPreview.address

            bindIcon(nameServiceAccountPreview)
            bindNamePreviewViewModel(nameServiceAccountPreview)
        }
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        bindIcon(accountPortfolioItem.accountValue.value)
    }
    
    mutating func bindNamePreviewViewModel(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        bindNamePreviewViewModel(
            accountPortfolioItem.accountValue.value
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        if !accountPortfolioItem.accountValue.isAvailable {
            primaryAccessory = nil
            return
        }

        let text = format(
            portfolioValue: accountPortfolioItem.portfolioValue,
            currencyValue: accountPortfolioItem.currency.primaryValue,
            in: .listItem
        )
        bindPrimaryAccessory(text)
    }
    
    mutating func bindSecondaryAccessory(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        if !accountPortfolioItem.accountValue.isAvailable {
            secondaryAccessory = nil
            return
        }

        let text = format(
            portfolioValue: accountPortfolioItem.portfolioValue,
            currencyValue: accountPortfolioItem.currency.secondaryValue,
            in: .listItem
        )
        bindSecondaryAccessory(text)
    }
    
    mutating func bindAccessoryIcon(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        bindAccessoryIcon(isValid: accountPortfolioItem.accountValue.isAvailable)
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ account: Account
    ) {
        icon = account.typeImage
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
    
    mutating func bindNamePreviewViewModel(
        _ customAccountPreview: CustomAccountPreview
    ) {
        namePreviewViewModel = AccountNamePreviewViewModel(
            title: customAccountPreview.title,
            subtitle: customAccountPreview.subtitle,
            with: .left
        )
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
        icon = iconWithShortAddressDraft.account.typeImage
    }

    mutating func bindNamePreviewViewModel(
        _ iconWithShortAddressDraft: IconWithShortAddressDraft
    ) {
        bindNamePreviewViewModel(
            iconWithShortAddressDraft.account
        )
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        icon = accountOrderingDraft.account.typeImage
    }

    mutating func bindNamePreviewViewModel(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        bindNamePreviewViewModel(accountOrderingDraft.account)
    }

    mutating func bindAccessoryIcon(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        accessoryIcon = "icon-order".templateImage
    }
}

extension AccountPreviewViewModel {
    mutating func bindNamePreviewViewModel(
        _ account: Account
    ) {
        namePreviewViewModel = AccountNamePreviewViewModel(
            account: account,
            with: .left
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            primaryAccessory = nil
            return
        }

        primaryAccessory = .attributedString(
            accessory.bodyMedium(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        )
    }
    
    mutating func bindSecondaryAccessory(
        _ accessory: String?
    ) {
        guard let accessory = accessory else {
            secondaryAccessory = nil
            return
        }
        
        secondaryAccessory = .attributedString(
            accessory.footnoteRegular(
                alignment: .right,
                lineBreakMode: .byTruncatingTail
            )
        )
    }
    
    mutating func bindAccessoryIcon(
        isValid: Bool
    ) {
        accessoryIcon = isValid ? nil : "icon-red-warning".uiImage
    }
}

extension AccountPreviewViewModel {
    mutating func bindIcon(
        _ nameServiceAccountPreview: NameServiceAccountPreview
    ) {
        icon = nameServiceAccountPreview.icon
    }

    mutating func bindNamePreviewViewModel(
        _ nameServiceAccountPreview: NameServiceAccountPreview
    ) {
        namePreviewViewModel = AccountNamePreviewViewModel(
            title: nameServiceAccountPreview.title,
            subtitle: nameServiceAccountPreview.subtitle,
            with: .left
        )
    }
}

extension AccountPreviewViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(address)
        hasher.combine(namePreviewViewModel)
        hasher.combine(primaryAccessory)
        hasher.combine(secondaryAccessory)
    }

    static func == (
        lhs: AccountPreviewViewModel,
        rhs: AccountPreviewViewModel
    ) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.namePreviewViewModel == rhs.namePreviewViewModel &&
            lhs.primaryAccessory == rhs.primaryAccessory &&
            lhs.secondaryAccessory == rhs.secondaryAccessory
    }
}

struct CustomAccountPreview {
    /// <note>
    /// For uniqueness purposes, we need to store the address of the account.
    var address: String?

    var icon: ImageSource?
    var title: String?
    var subtitle: String?
    var accessory: String?
    
    init(
        address: String,
        icon: UIImage?,
        title: String?,
        subtitle: String?
    ) {
        self.address = address

        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    /// <todo>
    /// We should check & remove `AccountNameViewModel` & `AuthAccountNameViewModel`.
    init(
        _ viewModel: AccountNameViewModel,
        address: String?
    ) {
        self.address = address

        icon = viewModel.image
        title = viewModel.name
        subtitle = nil
        accessory = nil
    }
    
    init(
        _ viewModel: AuthAccountNameViewModel,
        address: String?
    ) {
        self.address = address

        icon = viewModel.image
        title = viewModel.address
        subtitle = nil
        accessory = nil
    }

    init(
        _ viewModel: AlgoAccountViewModel,
        address: String?
    ) {
        self.address = address

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

struct AccountOrderingDraft {
    let account: Account
}

struct NameServiceAccountPreview {
    /// <note>
    /// For uniqueness purposes, we need to store the address of the account.
    let address: String?

    let icon: PNGImageSource?
    let title: String?
    let subtitle: String?

    init(
        address: String?,
        icon: PNGImageSource?,
        title: String?,
        subtitle: String?
    ) {
        self.address = address

        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}
