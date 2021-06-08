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
//  TabBarController.swift

import UIKit

class TabBarController: UIViewController {
    
    override var childForStatusBarHidden: UIViewController? {
        return selectedContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return selectedContent
    }
    
    var items: [TabBarItemConvertible] = [] {
        didSet {
            updateLayoutWhenItemsChanged()
        }
    }
    
    var selectedItem: TabBarItemConvertible? {
        didSet {
            if isDisplayingTransactionButtons {
                isDisplayingTransactionButtons = false
            }
            
            if let selectedItem = selectedItem {
                if !selectedItem.equalsTo(oldValue) {
                    updateLayoutWhenSelectedItemChanged()
                }
            } else {
                if oldValue != nil {
                    updateLayoutWhenSelectedItemChanged()
                }
            }
        }
    }
    
    private var isDisplayingTransactionButtons = false {
        didSet {
            if isDisplayingTransactionButtons {
                presentTransactionFlow()
            } else {
                hideTransactionFlow()
            }
        }
    }
    
    private var selectedContent: UIViewController?
    
    private lazy var modalScreenPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: 490.0))
    )
    
    private(set) lazy var tabBar = TabBar()

    private(set) lazy var sendButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setBackgroundImage(img("img-tabbar-send"), for: .normal)
        button.setImage(img("icon-arrow-up"), for: .normal)
        button.setTitle("title-send".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.primary, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private(set) lazy var receiveButton: AlignedButton = {
        let button = AlignedButton(.imageAtLeft(spacing: 4.0))
        button.setBackgroundImage(img("img-tabbar-receive"), for: .normal)
        button.setImage(img("icon-qr-20", isTemplate: true), for: .normal)
        button.tintColor = Colors.Background.secondary
        button.setTitle("title-receive".localized, for: .normal)
        button.setTitleColor(Colors.ButtonText.primary, for: .normal)
        button.titleLabel?.font = UIFont.font(withWeight: .semiBold(size: 14.0))
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private lazy var accountsViewController = AccountsViewController(configuration: configuration)
    private lazy var contactsViewController = ContactsViewController(configuration: configuration)
    private lazy var notificationsViewController = NotificationsViewController(configuration: configuration)
    private lazy var settingsViewController = SettingsViewController(configuration: configuration)
    
    private let configuration: ViewControllerConfiguration
    var route: Screen?
    
    private var assetAlertDraft: AssetAlertDraft?
    
    private var isAppeared = false

    init(configuration: ViewControllerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeAppearance()
        prepareLayout()
        setListeners()
        setupTabBarController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if let appConfiguration = UIApplication.shared.appConfiguration {
            appConfiguration.session.isValid = true
        }
        
        routeForDeeplink()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isAppeared = true
    }
    
    func customizeAppearance() {
        if !isDarkModeDisplay {
            applyShadows()
        }
    }

    func prepareLayout() {
        addTabBar()
        updateLayoutWhenItemsChanged()
    }

    func setListeners() {
        tabBar.barButtonDidSelect = { [unowned self] index in
            self.selectedItem = self.items[index]
        }
        
        tabBar.centerButtonDidTap = { [unowned self] _ in
            self.isDisplayingTransactionButtons = !self.isDisplayingTransactionButtons
        }
        
        sendButton.addTarget(self, action: #selector(notifyDelegateToOpenAssetSelectionForSendFlow), for: .touchUpInside)
        receiveButton.addTarget(self, action: #selector(notifyDelegateToOpenAssetSelectionForRequestFlow), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isDarkModeDisplay {
            sendButton.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 24.0)
            receiveButton.updateShadowLayoutWhenViewDidLayoutSubviews(cornerRadius: 24.0)
            tabBar.updateShadowLayoutWhenViewDidLayoutSubviews()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
                if traitCollection.userInterfaceStyle == .dark {
                    sendButton.removeShadow()
                    receiveButton.removeShadow()
                    tabBar.removeShadow()
                } else {
                    applyShadows()
                }
            }
        }
    }
    
    private func applyShadows() {
        sendButton.applyShadow(
            Shadow(color: ShadowColors.sendShadow, offset: CGSize(width: 0.0, height: 8.0), radius: 20.0, opacity: 1.0)
        )
        receiveButton.applyShadow(
            Shadow(color: ShadowColors.requestShadow, offset: CGSize(width: 0.0, height: 8.0), radius: 20.0, opacity: 1.0)
        )
        tabBar.applyShadow(tabBarShadow)
    }
}

extension TabBarController {
    private func setupTabBarController() {
        items = [
            AccountsTabBarItem(content: NavigationController(rootViewController: accountsViewController)),
            ContactsTabBarItem(content: NavigationController(rootViewController: contactsViewController)),
            TransactionTabBarItem(),
            NotificationsTabBarItem(content: NavigationController(rootViewController: notificationsViewController)),
            SettingsTabBarItem(content: NavigationController(rootViewController: settingsViewController))
        ]
    }
}

extension TabBarController {
    func routeForDeeplink() {
        if let route = route {
            self.route = nil
            switch route {
            case .addContact:
                selectedItem = items[1]
                topMostController?.open(route, by: .push)
            case .sendAlgosTransactionPreview,
                 .sendAssetTransactionPreview:
                selectedItem = items[0]
                topMostController?.open(route, by: .push)
            case .assetSupport:
                selectedItem = items[0]
                open(
                    route,
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        transitioningDelegate: modalScreenPresenter
                    )
                )
            case .assetDetail:
                topMostController?.open(route, by: .push)
            case let .assetActionConfirmation(draft):
                let controller = topMostController?.open(
                    route,
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        transitioningDelegate: modalScreenPresenter
                    )
                ) as? AssetActionConfirmationViewController
                
                assetAlertDraft = draft
                
                controller?.delegate = self
            default:
                break
            }
        }
    }
}

extension TabBarController: AssetActionConfirmationViewControllerDelegate {
    func assetActionConfirmationViewController(
        _ assetActionConfirmationViewController: AssetActionConfirmationViewController,
        didConfirmedActionFor assetDetail: AssetDetail
    ) {
        guard let account = assetAlertDraft?.account,
            let assetId = assetAlertDraft?.assetIndex,
            let api = UIApplication.shared.appConfiguration?.api else {
                return
        }
        
        let transactionController = TransactionController(api: api)
        
        let assetTransactionDraft = AssetTransactionSendDraft(from: account, assetIndex: Int64(assetId))
        transactionController.setTransactionDraft(assetTransactionDraft)
        transactionController.getTransactionParamsAndComposeTransactionData(for: .assetAddition)
        assetAlertDraft = nil
    }
}
    
extension TabBarController {
    @objc
    private func notifyDelegateToOpenAssetSelectionForSendFlow() {
        let controller = open(.selectAsset(transactionAction: .send), by: .present) as? SelectAssetViewController
        controller?.delegate = self
    }
    
    @objc
    private func notifyDelegateToOpenAssetSelectionForRequestFlow() {
        let controller = open(.selectAsset(transactionAction: .request), by: .present) as? SelectAssetViewController
        controller?.delegate = self
    }
}

extension TabBarController: SelectAssetViewControllerDelegate {
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelectAlgosIn account: Account,
        forAction transactionAction: TransactionAction
    ) {
        isDisplayingTransactionButtons = false
        
        let fullScreenPresentation = Screen.Transition.Open.customPresent(
            presentationStyle: .fullScreen,
            transitionStyle: nil,
            transitioningDelegate: nil
        )
        
        if transactionAction == .send {
            log(SendTabEvent())
            open(
                .sendAlgosTransactionPreview(
                    account: account,
                    receiver: .initial,
                    isSenderEditable: true
                ),
                by: fullScreenPresentation
            )
        } else {
            log(ReceiveTabEvent())
            let draft = QRCreationDraft(address: account.address, mode: .address)
            open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
        }
    }
    
    func selectAssetViewController(
        _ selectAssetViewController: SelectAssetViewController,
        didSelect assetDetail: AssetDetail,
        in account: Account,
        forAction transactionAction: TransactionAction
    ) {
        isDisplayingTransactionButtons = false
        
        let fullScreenPresentation = Screen.Transition.Open.customPresent(
            presentationStyle: .fullScreen,
            transitionStyle: nil,
            transitioningDelegate: nil
        )
        
        if transactionAction == .send {
            log(SendTabEvent())
            open(
                .sendAssetTransactionPreview(
                    account: account,
                    receiver: .initial,
                    assetDetail: assetDetail,
                    isSenderEditable: true,
                    isMaxTransaction: false
                ),
                by: fullScreenPresentation
            )
        } else {
            log(ReceiveTabEvent())
            let draft = QRCreationDraft(address: account.address, mode: .address)
            open(.qrGenerator(title: account.name ?? account.address.shortAddressDisplay(), draft: draft, isTrackable: true), by: .present)
        }
    }
}

extension TabBarController {
    func getBadge(forItemAt index: Int) -> String? {
        return tabBar.getBadge(forBarButtonAt: index)
    }

    func set(badge: String?, forItemAt index: Int, animated: Bool) {
        tabBar.set(badge: badge, forBarButtonAt: index, animated: animated)
    }
    
    func setTabBarHidden(_ isHidden: Bool, animated: Bool) {
        if isHidden && isDisplayingTransactionButtons {
            isDisplayingTransactionButtons = false
        }
        
        tabBar.snp.updateConstraints { maker in
            maker.bottom.equalToSuperview().inset(isHidden ? -tabBar.bounds.height : 0.0)
        }
        if !animated || !isAppeared { return }

        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) { [unowned self] in
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
}

extension TabBarController {
    func addTabBar() {
        view.addSubview(tabBar)
        tabBar.snp.makeConstraints { maker in
            maker.leading.equalToSuperview()
            maker.bottom.equalToSuperview()
            maker.trailing.equalToSuperview()
        }
    }

    func addNewSelectedContent() {
        if let content = selectedItem?.content {
            removeCurrentSelectedContent()
            selectedContent = addContent(content) { contentView in
                view.insertSubview(contentView, belowSubview: tabBar)
                contentView.snp.makeConstraints { maker in
                    maker.top.equalToSuperview()
                    maker.leading.equalToSuperview()
                    maker.trailing.equalToSuperview()
                    maker.bottom.equalTo(tabBar.snp.top)
                }
            }
        }
    }

    func removeCurrentSelectedContent() {
        selectedContent?.removeFromContainer()
        selectedContent = nil
    }
    
    func updateLayoutWhenItemsChanged() {
        tabBar.barButtonItems = items.map(\.barButtonItem)

        if selectedItem == nil {
            selectedItem = items.first
        } else {
            updateLayoutWhenSelectedItemChanged()
        }
    }

    func updateLayoutWhenSelectedItemChanged() {
        guard let selectedItem = selectedItem else {
            removeCurrentSelectedContent()
            tabBar.selectedBarButtonIndex = nil
            return
        }
        addNewSelectedContent()
        tabBar.selectedBarButtonIndex = items.firstIndex(of: selectedItem, equals: \.name)
    }
}

extension TabBarController {
    private enum ShadowColors {
        static let sendShadow = rgba(0.96, 0.44, 0.32, 0.25)
        static let requestShadow = rgba(0.34, 0.75, 0.71, 0.25)
    }
}

enum TransactionAction {
    case send
    case request
}
