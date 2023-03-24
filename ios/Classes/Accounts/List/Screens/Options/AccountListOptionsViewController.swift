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
//   AccountListOptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class AccountListOptionsViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var contextView = VStackView()

    private let accountType: AccountInformation.AccountType
    
    private let theme: AccountListOptionsViewControllerTheme

    init(
        accountType: AccountInformation.AccountType,
        configuration: ViewControllerConfiguration,
        theme: AccountListOptionsViewControllerTheme = .init()
    ) {
        self.accountType = accountType
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }
    
    private func build() {
        addBackground()
        addContext()
        addButtons()
    }
}

extension AccountListOptionsViewController {
    private func addBackground() {
        view.customizeAppearance(theme.background)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func addButtons() {
        addAddAccountButton()
        addArrangeAccountsButton()
    }
    
    private func addAddAccountButton() {
        addButton(
            AddAccountListItemButtonViewModel(),
            #selector(addAccount)
        )
    }
    
    private func addArrangeAccountsButton() {
        addButton(
            ArrangeListListItemButtonViewModel(),
            #selector(arrangeAccounts)
        )
    }
    
    private func addButton(
        _ viewModel: ListItemButtonViewModel,
        _ selector: Selector
    ) {
        let button = ListItemButton()
        
        button.customize(theme.button)
        button.bindData(viewModel)
        
        contextView.addArrangedSubview(button)
        
        button.addTouch(
            target: self,
            action: selector
        )
    }
}

extension AccountListOptionsViewController {
    @objc
    private func addAccount() {
        eventHandler?(.addAccount)
    }
    
    @objc
    private func arrangeAccounts() {
        eventHandler?(.arrangeAccounts(accountType))
    }
}

extension AccountListOptionsViewController {
    enum Event {
        case addAccount
        case arrangeAccounts(AccountInformation.AccountType)
    }
}
