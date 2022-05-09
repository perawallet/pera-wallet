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
//  TabBarController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class TabBarController: TabBarContainer {
    var route: Screen?
    
    var selectedTab: TabBarItemID? {
        get {
            let item = items[safe: selectedIndex]
            return item.unwrap { TabBarItemID(rawValue: $0.id) }
        }
        set {
            selectedIndex = newValue.unwrap { items.index(of: $0) }
        }
    }

    private lazy var toggleTransactionOptionsActionView = Button()
    private lazy var transactionOptionsView = createTransactionOptions()

    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)
    
    private var isTransactionOptionsVisible: Bool = false
    private var currentTransactionOptionsAnimator: UIViewPropertyAnimator?
    
    override func addTabBar() {
        super.addTabBar()
        
        tabBar.customizeAppearance(
            [
                .backgroundColor(AppColors.Shared.System.background)
            ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.appConfiguration?.session.isValid = true
    }
    
    override func updateLayoutWhenItemsDidChange() {
        super.updateLayoutWhenItemsDidChange()
        
        if items.isEmpty {
            removeShowTransactionOptionsAction()
        } else {
            addShowTransactionOptionsAction()
        }
    }
}

extension TabBarController {
    private func build() {
        addBackground()
        
        if !items.isEmpty {
            addShowTransactionOptionsAction()
        }
    }
    
    private func addBackground() {
        customizeViewAppearance(
            [
                .backgroundColor(AppColors.Shared.System.background)
            ]
        )
    }
    
    private func addShowTransactionOptionsAction() {
        toggleTransactionOptionsActionView.customizeAppearance(
            [
                .icon([
                    .normal("tabbar-icon-transaction"),
                    .selected("tabbar-icon-transaction-selected")
                ])
            ]
        )
        
        tabBar.addSubview(toggleTransactionOptionsActionView)
        toggleTransactionOptionsActionView.fitToIntrinsicSize()
        toggleTransactionOptionsActionView.snp.makeConstraints {
            $0.centerX == 0
            $0.top == 0
        }
        
        toggleTransactionOptionsActionView.addTouch(
            target: self,
            action: #selector(toggleTransactionOptions))
    }
    
    private func removeShowTransactionOptionsAction() {
        toggleTransactionOptionsActionView.removeFromSuperview()
    }
    
    private func createTransactionOptions() -> TransactionOptionsView {
        var theme = TransactionOptionsViewTheme()
        theme.contentSafeAreaInsets =
            UIEdgeInsets(top: 0, left: 0, bottom: tabBar.bounds.height, right: 0)
        
        let aView = TransactionOptionsView()
        aView.customize(theme)
        aView.observe(event: .send) {
            [weak self] in
            guard let self = self else { return }
            self.navigateToAccountSelection(.send)
        }
        aView.observe(event: .receive) {
            [weak self] in
            guard let self = self else { return }
            self.navigateToAccountSelection(.receive)
        }
        aView.observe(event: .buyAlgo) {
            [weak self] in
            guard let self = self else { return }
            self.navigateToBuyAlgo()
        }
        aView.observe(event: .close) {
            [weak self] in
            guard let self = self else { return }
            self.toggleTransactionOptions()
        }
        return aView
    }
    
    private func addTransactionOptions() {
        if transactionOptionsView.isDescendant(of: view) {
            return
        }
        
        view.insertSubview(
            transactionOptionsView,
            belowSubview: tabBar
        )
        transactionOptionsView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }
    
    private func removeTransactionOptions() {
        transactionOptionsView.removeFromSuperview()
    }
}

extension TabBarController {
    @objc
    private func toggleTransactionOptions() {
        toggleTransactionOptionsActionView.isSelected.toggle()
        setTabBarItemsEnabled(!toggleTransactionOptionsActionView.isSelected)
        
        if let currentTransactionOptionsAnimator = currentTransactionOptionsAnimator,
           currentTransactionOptionsAnimator.isRunning {
            currentTransactionOptionsAnimator.isReversed.toggle()
            return
        }
        
        if isTransactionOptionsVisible {
            hideTransactionOptionsAnimated()
        } else {
            showTransactionOptionsAnimated()
        }
    }
    
    private func showTransactionOptionsAnimated() {
        addTransactionOptions()
        view.layoutIfNeeded()
        
        currentTransactionOptionsAnimator = makeTransactionOptionsAnimator(for: .end)
        currentTransactionOptionsAnimator?.addCompletion { [weak self] position in
            guard let self = self else { return }
            
            switch position {
            case .start:
                self.transactionOptionsView.updateBeforeAnimations(for: .start)
            case .end:
                self.isTransactionOptionsVisible = true
            default:
                break
            }
        }
        currentTransactionOptionsAnimator?.startAnimation()
    }
    
    private func hideTransactionOptionsAnimated() {
        currentTransactionOptionsAnimator = makeTransactionOptionsAnimator(for: .start)
        currentTransactionOptionsAnimator?.addCompletion { [weak self] position in
            guard let self = self else { return }
            
            switch position {
            case .start:
                self.transactionOptionsView.updateBeforeAnimations(for: .end)
            case .end:
                self.removeTransactionOptions()
                self.isTransactionOptionsVisible = false
            default:
                break
            }
        }
        currentTransactionOptionsAnimator?.startAnimation()
    }
    
    private func makeTransactionOptionsAnimator(
        for position: TransactionOptionsView.Position
    ) -> UIViewPropertyAnimator {
        transactionOptionsView.updateBeforeAnimations(for: position)

        return UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
            [unowned self] in
            
            self.transactionOptionsView.updateAlongsideAnimations(for: position)
            self.view.layoutIfNeeded()
        }
    }
}

extension TabBarController {
    private func navigateToAccountSelection(
        _ action: TransactionAction
    ) {
        toggleTransactionOptions()
        
        open(
            .accountSelection(transactionAction: action, delegate: self),
            by: .present
        )
        
        switch action {
        case .send: log(SendTabEvent())
        case .receive: log(ReceiveTabEvent())
        case .buyAlgo:
            break
        }
    }

    private func navigateToBuyAlgo() {
        toggleTransactionOptions()

        launchBuyAlgo()
    }
}

extension TabBarController: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        if transactionAction == .send {
            selectAccountViewController.open(
                .assetSelection(
                    filter: nil,
                    account: account
                ),
                by: .push
            )
        } else {
            selectAccountViewController.closeScreen(by: .dismiss) { [weak self] in
                guard let self = self else {
                    return
                }

                let draft = QRCreationDraft(address: account.address, mode: .address, title: account.name)
                self.open(
                    .qrGenerator(
                        title: account.name ?? account.address.shortAddressDisplay,
                        draft: draft, isTrackable: true),
                    by: .present
                )
            }
        }
    }
}

extension Array where Element == TabBarItem {
    func index(
        of itemId: TabBarItemID
    ) -> Int? {
        return firstIndex { $0.id == itemId.rawValue }
    }
}

/// <todo>
/// Move it to 'Macaroon' later.
extension TabBarContainer {
    func setTabBarItemsEnabled(
        _ isEnabled: Bool
    ) {
        items.enumerated().forEach {
            if $1.isSelectable {
                tabBar.barButtons[$0].isEnabled = isEnabled
            }
        }
    }
}
