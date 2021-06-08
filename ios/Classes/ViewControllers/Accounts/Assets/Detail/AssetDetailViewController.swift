// Copyright 2019 Algorand, Inc.

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
//  AccountDetailViewController.swift

import UIKit
import SnapKit

class AssetDetailViewController: BaseViewController {
    
    override var name: AnalyticsScreenName? {
        return .assetDetail
    }
    
    private var account: Account
    private var assetDetail: AssetDetail?
    var route: Screen?
    
    var transactionsTopConstraint: Constraint?
    
    private lazy var transactionActionsView = TransactionActionsView()
    
    private lazy var assetDetailTitleView = AssetDetailTitleView(title: account.name)
    
    private lazy var assetCardDisplayViewController: AssetCardDisplayViewController = {
        var selectedIndex = 0
        if let assetDetail = assetDetail {
            selectedIndex = (account.assetDetails.firstIndex(of: assetDetail) ?? 0) + 1
        }
        
        return AssetCardDisplayViewController(account: account, selectedIndex: selectedIndex, configuration: configuration)
    }()
    
    private lazy var transactionsViewController = TransactionsViewController(
        account: account,
        configuration: configuration,
        assetDetail: assetDetail
    )
    
    init(account: Account, configuration: ViewControllerConfiguration, assetDetail: AssetDetail? = nil) {
        self.account = account
        self.assetDetail = assetDetail
        super.init(configuration: configuration)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleDeepLinkRoutingIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log(DisplayAssetDetailEvent(assetId: assetDetail?.id))
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.titleView = assetDetailTitleView
        assetDetailTitleView.bind(AssetDetailTitleViewModel(account: account, assetDetail: assetDetail))
    }
    
    override func linkInteractors() {
        transactionActionsView.delegate = self
        assetCardDisplayViewController.delegate = self
    }
    
    override func setListeners() {
        super.setListeners()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AccountUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didAccountUpdate(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
    }
    
    override func prepareLayout() {
        setupAssetCardDisplayViewController()
        if !account.isWatchAccount() {
            setupTransactionActionsViewLayout()
        }
        setupTransactionsViewController()
    }
}

extension AssetDetailViewController {
    private func setupAssetCardDisplayViewController() {
        addChild(assetCardDisplayViewController)
        view.addSubview(assetCardDisplayViewController.view)

        assetCardDisplayViewController.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(AssetCardDisplayView.CardViewConstants.height)
        }
        
        assetCardDisplayViewController.didMove(toParent: self)
    }
    
    private func setupTransactionActionsViewLayout() {
        view.addSubview(transactionActionsView)
        
        transactionActionsView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaBottom + 92.0)
        }
    }
    
    private func setupTransactionsViewController() {
        addChild(transactionsViewController)
        view.addSubview(transactionsViewController.view)

        transactionsViewController.view.snp.makeConstraints { make in
            transactionsTopConstraint = make.top.equalTo(assetCardDisplayViewController.view.snp.bottom).offset(0.0).constraint
            make.leading.trailing.equalToSuperview()
            
            if account.isWatchAccount() {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(transactionActionsView.snp.top)
            }
        }

        transactionsViewController.delegate = self
        transactionsViewController.didMove(toParent: self)
    }
}

extension AssetDetailViewController {
    private func handleDeepLinkRoutingIfNeeded() {
        if let route = route {
            switch route {
            case .assetDetail:
                self.route = nil
                updateLayout()
            default:
                self.route = nil
                open(route, by: .push, animated: false)
            }
        }
    }
    
    private func updateLayout() {
        guard let account = session?.account(from: account.address) else {
            return
        }
        
        assetCardDisplayViewController.updateAccount(account)
        transactionsViewController.updateList()
    }
}

extension AssetDetailViewController {
    @objc
    private func didAccountUpdate(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Account],
            let updatedAccount = userInfo["account"] else {
            return
        }
        
        if account == updatedAccount {
            account = updatedAccount
            updateLayout()
        }
    }
}

extension AssetDetailViewController: TransactionsViewControllerDelegate {
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didScroll scrollView: UIScrollView) {
        if transactionsViewController.isTransactionListEmpty {
            return
        }
        
        let headerHeight = AssetCardDisplayView.CardViewConstants.height
        
        let scrollOffset = scrollView.panGestureRecognizer.translation(in: view).y
        let isScrollDirectionUp = scrollOffset < 0
        
        var offset: CGFloat = 0.0
        
        if isScrollDirectionUp {
            offset = -scrollOffset > headerHeight ? headerHeight : scrollOffset
            if offset == headerHeight || transactionsViewController.view.frame.minY <= 5.0 {
                assetDetailTitleView.animateUp(with: 1.0)
                transactionsTopConstraint?.update(offset: -headerHeight)
                return
            } else {
                assetDetailTitleView.animateUp(with: -scrollOffset / headerHeight)
                scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        } else {
            if scrollView.contentOffset.y > 0.0 {
                return
            }
            
            offset = scrollOffset > headerHeight ? 0.0 : scrollOffset - headerHeight
            if offset == 0.0 || transactionsViewController.view.frame.minY >= headerHeight {
                assetDetailTitleView.animateDown(with: 1.0)
                transactionsTopConstraint?.update(offset: 0.0)
                return
            } else {
                assetDetailTitleView.animateDown(with: scrollOffset / headerHeight)
                scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
            }
        }
        
        transactionsTopConstraint?.update(offset: offset)
        view.layoutIfNeeded()
    }
    
    func transactionsViewController(_ transactionsViewController: TransactionsViewController, didStopScrolling scrollView: UIScrollView) {
        if transactionsViewController.isTransactionListEmpty {
            return
        }
        
        let headerHeight = AssetCardDisplayView.CardViewConstants.height
        
        let isScrollDirectionUp = scrollView.panGestureRecognizer.translation(in: view).y < 0
        
        if isScrollDirectionUp {
            if transactionsViewController.view.frame.minY <= 5.0 {
                return
            }
            
            assetDetailTitleView.animateUp(with: 1.0)
            updateScrollOffset(-headerHeight)
            
            if transactionsViewController.view.frame.minY <= 5.0 {
                return
            }
            
            view.layoutIfNeeded()
            scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: false)
        } else {
            if transactionsViewController.view.frame.minY >= headerHeight {
                return
            }
            
            assetDetailTitleView.animateDown(with: 1.0)
            updateScrollOffset(0.0)
        }
    }
    
    private func updateScrollOffset(_ offset: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.transactionsTopConstraint?.update(offset: offset)
            self.view.layoutIfNeeded()
        }
    }
}

extension AssetDetailViewController: TransactionActionsViewDelegate {
    func transactionActionsViewDidSendTransaction(_ transactionActionsView: TransactionActionsView) {
        log(SendAssetDetailEvent(address: account.address))
        if let assetDetail = assetDetail {
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false
                ),
                by: .push
            )
        } else {
            open(.sendAlgosTransactionPreview(account: account, receiver: .initial, isSenderEditable: false), by: .push)
        }
    }
    
    func transactionActionsViewDidRequestTransaction(_ transactionActionsView: TransactionActionsView) {
        log(ReceiveAssetDetailEvent(address: account.address))
        let draft = QRCreationDraft(address: account.address, mode: .address)
        open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
    }
}

extension AssetDetailViewController: AssetCardDisplayViewControllerDelegate {
    func assetCardDisplayViewController(_ assetCardDisplayViewController: AssetCardDisplayViewController, didSelect index: Int) {
        assetDetail = index == 0 ? nil : account.assetDetails[safe: index - 1]
        log(ChangeAssetDetailEvent(assetId: assetDetail?.id))
        assetDetailTitleView.bind(AssetDetailTitleViewModel(account: account, assetDetail: assetDetail))
        transactionsViewController.updateSelectedAsset(assetDetail)
    }
}
