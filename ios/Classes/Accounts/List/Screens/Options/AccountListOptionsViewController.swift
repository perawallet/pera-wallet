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
    BottomSheetPresentable {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var contextView = VStackView()

    private let accountType: AccountType
    
    private let theme: AccountListOptionsViewControllerTheme

    init(
        accountType: AccountType,
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
        addActions()
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
    
    private func addActions() {
        addAddAccountAction()
        addArrangeAccountsAction()
    }
    
    private func addAddAccountAction() {
        addAction(
            AddAccountListActionViewModel(),
            #selector(addAccount)
        )
    }
    
    private func addArrangeAccountsAction() {
        addAction(
            ArrangeListListActionVIewModel(),
            #selector(arrangeAccounts)
        )
    }
    
    private func addAction(
        _ viewModel: ListActionViewModel,
        _ selector: Selector
    ) {
        let actionView = ListActionView()
        
        actionView.customize(theme.action)
        actionView.bindData(viewModel)
        
        contextView.addArrangedSubview(actionView)
        
        actionView.addTouch(
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
        case arrangeAccounts(AccountType)
    }
}
