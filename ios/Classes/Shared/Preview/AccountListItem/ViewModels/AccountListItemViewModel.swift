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
//   AccountListItemViewModel.swift

import Foundation
import MacaroonUIKit
import UIKit
import MacaroonURLImage

struct AccountListItemViewModel:
    PortfolioViewModel,
    BindableViewModel,
    Hashable {

    private(set) var address: String?
    private(set) var icon: ImageSource?
    private(set) var title: AccountPreviewTitleViewModel?
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

extension AccountListItemViewModel {
    mutating func bind<T>(
        _ model: T
    ) {
        if let accountPortfolioItem = model as? AccountPortfolioItem {
            address = accountPortfolioItem.accountValue.value.address
            currencyFormatter = accountPortfolioItem.currencyFormatter

            bindIcon(accountPortfolioItem)
            bindTitle(accountPortfolioItem)
            bindPrimaryAccessory(accountPortfolioItem)
            bindSecondaryAccessory(accountPortfolioItem)
            bindAccessoryIcon(accountPortfolioItem)

            return
        }
        
        if let account = model as? Account {
            address = account.address
            
            bindIcon(account)
            bindTitle(account)
            bindPrimaryAccessory(account)
            bindSecondaryAccessory(account)
            bindAccessoryIcon(account)
            
            return
        }
        
        if let customAccountListItem = model as? CustomAccountListItem {
            address = customAccountListItem.address

            bindIcon(customAccountListItem)
            bindTitle(customAccountListItem)
            bindPrimaryAccessory(customAccountListItem)
            bindSecondaryAccessory(customAccountListItem)
            bindAccessoryIcon(customAccountListItem)
            
            return
        }

        if let accountOrderingDraft = model as? AccountOrderingDraft {
            address = accountOrderingDraft.account.address

            bindIcon(accountOrderingDraft)
            bindTitle(accountOrderingDraft)
            bindAccessoryIcon(accountOrderingDraft)
        }

        if let iconWithShortAddressDraft = model as? IconWithShortAddressDraft {
            address = iconWithShortAddressDraft.account.address

            bindIcon(iconWithShortAddressDraft)
            bindTitle(iconWithShortAddressDraft)

            return
        }

        if let mameServiceAccountListItem = model as? NameServiceAccountListItem {
            address = mameServiceAccountListItem.address

            bindIcon(mameServiceAccountListItem)
            bindTitle(mameServiceAccountListItem)
        }
    }
}

extension AccountListItemViewModel {
    mutating func bindIcon(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        bindIcon(accountPortfolioItem.accountValue.value)
    }
    
    mutating func bindTitle(
        _ accountPortfolioItem: AccountPortfolioItem
    ) {
        bindTitle(
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

extension AccountListItemViewModel {
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

extension AccountListItemViewModel {
    mutating func bindIcon(
        _ customAccountListItem: CustomAccountListItem
    ) {
        icon = customAccountListItem.icon
    }

    mutating func bindTitle(
        _ customAccountPreview: CustomAccountListItem
    ) {
        title = AccountPreviewTitleViewModel(
            primaryTitle: customAccountPreview.title,
            secondaryTitle: customAccountPreview.subtitle
        )
    }
    
    mutating func bindPrimaryAccessory(
        _ customAccountListItem: CustomAccountListItem
    ) {
        bindPrimaryAccessory(customAccountListItem.accessory)
    }
    
    mutating func bindSecondaryAccessory(
        _ customAccountListItem: CustomAccountListItem
    ) {
        secondaryAccessory = nil
    }
    
    mutating func bindAccessoryIcon(
        _ customAccountListItem: CustomAccountListItem
    ) {
        accessoryIcon = nil
    }
}

extension AccountListItemViewModel {
    mutating func bindIcon(
        _ iconWithShortAddressDraft: IconWithShortAddressDraft
    ) {
        icon = iconWithShortAddressDraft.account.typeImage
    }

    mutating func bindTitle(
        _ iconWithShortAddressDraft: IconWithShortAddressDraft
    ) {
        bindTitle(
            iconWithShortAddressDraft.account
        )
    }
}

extension AccountListItemViewModel {
    mutating func bindIcon(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        icon = accountOrderingDraft.account.typeImage
    }

    mutating func bindTitle(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        bindTitle(accountOrderingDraft.account)
    }

    mutating func bindAccessoryIcon(
        _ accountOrderingDraft: AccountOrderingDraft
    ) {
        accessoryIcon = "icon-order".templateImage
    }
}

extension AccountListItemViewModel {
    mutating func bindTitle(
        _ account: Account
    ) {
        title = AccountPreviewTitleViewModel(account: account)
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

extension AccountListItemViewModel {
    mutating func bindIcon(
        _ mameServiceAccountListItem: NameServiceAccountListItem
    ) {
        icon = mameServiceAccountListItem.icon
    }

    mutating func bindTitle(
        _ nameServiceAccountListItem: NameServiceAccountListItem
    ) {
        title = AccountPreviewTitleViewModel(
            primaryTitle: nameServiceAccountListItem.title,
            secondaryTitle: nameServiceAccountListItem.subtitle
        )
    }
}

extension AccountListItemViewModel {
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(address)
        hasher.combine(title)
        hasher.combine(primaryAccessory)
        hasher.combine(secondaryAccessory)
    }

    static func == (
        lhs: AccountListItemViewModel,
        rhs: AccountListItemViewModel
    ) -> Bool {
        return
            lhs.address == rhs.address &&
            lhs.title == rhs.title &&
            lhs.primaryAccessory == rhs.primaryAccessory &&
            lhs.secondaryAccessory == rhs.secondaryAccessory
    }
}

struct CustomAccountListItem {
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

struct NameServiceAccountListItem {
    /// <note>
    /// For uniqueness purposes, we need to store the address of the account.
    let address: String?

    let icon: DefaultURLImageSource?
    let title: String?
    let subtitle: String?

    init(
        address: String?,
        icon: DefaultURLImageSource?,
        title: String?,
        subtitle: String?
    ) {
        self.address = address

        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}
