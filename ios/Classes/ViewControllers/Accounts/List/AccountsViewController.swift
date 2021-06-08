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
//  AccountsViewController.swift

import UIKit
import Magpie
import SVProgressHUD

class AccountsViewController: BaseViewController {
    
    override var shouldShowNavigationBar: Bool {
        return false
    }
    
    let layout = Layout<LayoutConstants>()
    
    private lazy var optionsModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.optionsModalHeight))
    )
    
    private(set) lazy var removeAccountModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .scroll
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.removeAccountModalHeight))
    )
    
    private(set) lazy var termsServiceModalPresenter = CardModalPresenter(
        config: ModalConfiguration(
            animationMode: .normal(duration: 0.25),
            dismissMode: .none
        ),
        initialModalSize: .custom(CGSize(width: view.frame.width, height: layout.current.termsAndServiceHeight))
    )
    
    private(set) lazy var passphraseModalPresenter: CardModalPresenter = {
        let screenHeight = UIScreen.main.bounds.height
        let height = screenHeight <= 606.0 ? screenHeight - 20.0 : 606.0
        return CardModalPresenter(
            config: ModalConfiguration(
                animationMode: .normal(duration: 0.25),
                dismissMode: .scroll
            ),
            initialModalSize: .custom(CGSize(width: view.frame.width, height: height))
        )
    }()
    
    private lazy var pushNotificationController: PushNotificationController = {
        guard let api = api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return PushNotificationController(api: api)
    }()

    private lazy var accountManager: AccountManager = {
        guard let api = self.api else {
            fatalError("Api must be set before accessing this view controller.")
        }
        return AccountManager(api: api)
    }()
    
    private(set) lazy var accountsView = AccountsView()
    private lazy var noConnectionView = NoInternetConnectionView()
    private lazy var emptyStateView = AccountsEmptyStateView()
    private lazy var refreshControl = UIRefreshControl()
    
    private(set) var selectedAccount: Account?
    private(set) var localAuthenticator = LocalAuthenticator()
    
    private(set) var accountsDataSource: AccountsDataSource
    
    override var name: AnalyticsScreenName? {
        return .accounts
    }
    
    private var isConnectedToInternet = true {
        didSet {
            if isConnectedToInternet == oldValue {
                return
            }
            
            if isConnectedToInternet {
                refreshAccounts()
            } else {
                accountsDataSource.accounts.removeAll()
                accountsView.accountsCollectionView.contentState = .empty(noConnectionView)
                accountsView.setHeaderButtonsHidden(true)
                accountsView.accountsCollectionView.reloadData()
            }
        }
    }
    
    override init(configuration: ViewControllerConfiguration) {
        accountsDataSource = AccountsDataSource()
        super.init(configuration: configuration)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAuthenticatedUser(notification:)),
            name: .AuthenticatedUserUpdate,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdateAccount(notification:)),
            name: .AccountUpdate,
            object: nil
        )
    }
    
    override func customizeTabBarAppearence() {
        isTabBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAccountsIfNeeded()
        
        DispatchQueue.main.async {
            UIApplication.shared.appDelegate?.validateAccountManagerFetchPolling()
        }
        
        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()
        
        setAccountsCollectionViewContentState()
        requestAppReview()
        presentPasscodeFlowIfNeeded()
    }

    private func fetchAccountsIfNeeded() {
        guard let session = session,
              let user = session.authenticatedUser,
              !session.hasPassword(),
              !user.accounts.isEmpty else {
            return
        }

        SVProgressHUD.show(withStatus: "title-loading".localized)
        accountManager.fetchAllAccounts(isVerifiedAssetsIncluded: true) {
            SVProgressHUD.showSuccess(withStatus: "title-done".localized)
            SVProgressHUD.dismiss(withDelay: 1.0) {
                DispatchQueue.main.async {
                    self.accountsView.accountsCollectionView.reloadData()
                    self.setAccountsCollectionViewContentState(isInitialEmptyStateIncluded: true)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if accountsDataSource.hasPendingAssetAction {
            accountsView.accountsCollectionView.reloadData()
        }
        
        displayTestNetBannerIfNeeded()
        api?.addListener(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentQRTooltipIfNeeded()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        api?.removeListener(self)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        navigationItem.title = "tabbar-item-accounts".localized
        accountsView.accountsCollectionView.refreshControl = refreshControl
    }
    
    override func setListeners() {
        accountsDataSource.delegate = self
        accountsView.delegate = self
        accountsView.accountsCollectionView.delegate = accountsDataSource
        accountsView.accountsCollectionView.dataSource = accountsDataSource
        emptyStateView.delegate = self
    }
    
    override func linkInteractors() {
        refreshControl.addTarget(self, action: #selector(didRefreshList), for: .valueChanged)
    }
    
    override func prepareLayout() {
        setupAccountsViewLayout()
    }
}

extension AccountsViewController {
    private func setupAccountsViewLayout() {
        view.addSubview(accountsView)
        
        accountsView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.safeEqualToTop(of: self)
        }
    }
}

extension AccountsViewController {
    private func requestAppReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            AlgorandAppStoreReviewer().requestReviewIfAppropriate()
        }
    }

    private func presentPasscodeFlowIfNeeded() {
        guard let session = session,
              !session.hasPassword() else {
            return
        }

        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()

        if !passcodeSettingDisplayStore.hasPermissionToAskAgain {
            return
        }

        passcodeSettingDisplayStore.increaseAppOpenCount()

        if passcodeSettingDisplayStore.shouldAskForPasscode {
            let controller = open(
                .animatedTutorial(flow: .none, tutorial: .passcode, isActionable: true),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? AnimatedTutorialViewController
            controller?.delegate = self
        }
    }
}

extension AccountsViewController: AnimatedTutorialViewControllerDelegate {
    func animatedTutorialViewControllerDidTapDontAskAgain(_ animatedTutorialViewController: AnimatedTutorialViewController) {
        animatedTutorialViewController.dismissScreen()
        var passcodeSettingDisplayStore = PasscodeSettingDisplayStore()
        passcodeSettingDisplayStore.disableAskingPasscode()
    }
}

extension AccountsViewController: AccountsDataSourceDelegate {
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didSelectAt indexPath: IndexPath) {
        selectedAccount = accountsDataSource.accounts[indexPath.section]
        guard let account = selectedAccount else {
            return
        }
        
        if indexPath.item == 0 {
            open(.assetDetail(account: account, assetDetail: nil), by: .push)
        } else {
            let assetDetail = account.assetDetails[indexPath.item - 1]
            open(.assetDetail(account: account, assetDetail: assetDetail), by: .push)
        }
    }
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapOptionsButtonFor account: Account) {
        selectedAccount = account
        presentOptions(for: account)
    }
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapAddAssetButtonFor account: Account) {
        selectedAccount = account
        let controller = open(.addAsset(account: account), by: .push)
        (controller as? AssetAdditionViewController)?.delegate = self
    }
    
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapQRButtonFor account: Account) {
        let draft = QRCreationDraft(address: account.address, mode: .address)
        open(.qrGenerator(title: "qr-creation-sharing-title".localized, draft: draft, isTrackable: true), by: .present)
    }
}

extension AccountsViewController: AccountsViewDelegate {
    func accountsViewDidTapQRButton(_ accountsView: AccountsView) {
        let qrScannerViewController = open(.qrScanner, by: .push) as? QRScannerViewController
        qrScannerViewController?.delegate = self
    }
    
    func accountsViewDidTapAddButton(_ accountsView: AccountsView) {
        openWelcomeScreen()
    }
}

extension AccountsViewController: AssetAdditionViewControllerDelegate {
    func assetAdditionViewController(
        _ assetAdditionViewController: AssetAdditionViewController,
        didAdd assetSearchResult: AssetSearchResult,
        to account: Account
    ) {
        guard let section = accountsDataSource.section(for: account) else {
            return
        }

        let assetDetail = AssetDetail(searchResult: assetSearchResult)
        assetDetail.isRecentlyAdded = true

        let index = accountsView.accountsCollectionView.numberOfItems(inSection: section)
        accountsDataSource.add(assetDetail: assetDetail, to: account)
        accountsView.accountsCollectionView.insertItems(at: [IndexPath(item: index, section: section)])
    }
}

extension AccountsViewController {
    @objc
    private func didUpdateAuthenticatedUser(notification: Notification) {
        if !isConnectedToInternet {
            return
        }
        
        accountsDataSource.reload()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didUpdateAccount(notification: Notification) {
        if !isConnectedToInternet {
            return
        }
        
        pushNotificationController.sendDeviceDetails()
        
        accountsDataSource.reload()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
    
    @objc
    private func didRefreshList() {
        if !isConnectedToInternet {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
            return
        }
        
        refreshAccounts()
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
    
    private func refreshAccounts() {
        accountsDataSource.refresh()
        setAccountsCollectionViewContentState()
        accountsView.accountsCollectionView.reloadData()
    }
}

extension AccountsViewController {
    private func presentOptions(for account: Account) {
        let transitionStyle = Screen.Transition.Open.customPresent(
            presentationStyle: .custom,
            transitionStyle: nil,
            transitioningDelegate: optionsModalPresenter
        )
        
        let optionsViewController = open(.options(account: account), by: transitionStyle) as? OptionsViewController
        
        optionsViewController?.delegate = self
    }
    
    private func setAccountsCollectionViewContentState(isInitialEmptyStateIncluded: Bool = false) {
        guard let user = session?.authenticatedUser else {
            return
        }

        if user.accounts.isEmpty {
            setEmptyAccountsState()
            return
        }

        if let remoteAccounts = session?.accounts,
           remoteAccounts.isEmpty,
           isInitialEmptyStateIncluded {
            setEmptyAccountsState()
            return
        }

        accountsView.accountsCollectionView.contentState = isConnectedToInternet ? .none : .empty(noConnectionView)
        accountsView.setHeaderButtonsHidden(!isConnectedToInternet)
    }

    func setEmptyAccountsState() {
        emptyStateView.bind(EmptyStateViewModel(emptyState: .accounts))
        accountsView.accountsCollectionView.contentState = .empty(emptyStateView)
        accountsView.setHeaderButtonsHidden(true)
    }
    
    private func displayTestNetBannerIfNeeded() {
        guard let isTestNet = api?.isTestNet else {
            return
        }
        
        accountsView.setTestNetLabelHidden(!isTestNet)
    }
}

extension AccountsViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            open(.addContact(mode: .new(address: qrText.address, name: qrText.label)), by: .push)
        case .algosRequest:
            guard let address = qrText.address,
                let amount = qrText.amount else {
                return
            }

            open(
                .sendAlgosTransactionPreview(
                    account: nil,
                    receiver: .address(address: address, amount: "\(amount)"),
                    isSenderEditable: true,
                    qrText: qrText
                ),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        case .assetRequest:
            guard let address = qrText.address,
                let amount = qrText.amount,
                let assetId = qrText.asset else {
                return
            }
            
            var asset: AssetDetail?
            
            for account in accountsDataSource.accounts {
                for assetDetail in account.assetDetails where assetDetail.id == assetId {
                    asset = assetDetail
                    break
                }
            }
            
            guard let assetDetail = asset else {
                let assetAlertDraft = AssetAlertDraft(
                    account: nil,
                    assetIndex: assetId,
                    assetDetail: nil,
                    title: "asset-support-your-add-title".localized,
                    detail: "asset-support-your-add-message".localized,
                    actionTitle: "title-ok".localized
                )
                
                open(
                    .assetSupport(assetAlertDraft: assetAlertDraft),
                    by: .customPresentWithoutNavigationController(
                        presentationStyle: .custom,
                        transitionStyle: nil,
                        transitioningDelegate: optionsModalPresenter
                    )
                )
                return
            }
            
            open(
                .sendAssetTransactionPreview(
                    account: nil,
                    receiver: .address(
                        address: address,
                        amount: amount
                            .assetAmount(fromFraction: assetDetail.fractionDecimals)
                            .toFractionStringForLabel(fraction: assetDetail.fractionDecimals)
                    ),
                    assetDetail: assetDetail,
                    isSenderEditable: false,
                    isMaxTransaction: false,
                    qrText: qrText
                ),
                by: .push
            )
        case .mnemonic:
            break
        }
    }
    
    func qrScannerViewController(_ controller: QRScannerViewController, didFail error: QRScannerError, completionHandler: EmptyHandler?) {
        displaySimpleAlertWith(title: "title-error".localized, message: "qr-scan-should-scan-valid-qr".localized) { _ in
            if let handler = completionHandler {
                handler()
            }
        }
    }
}

extension AccountsViewController: AccountsEmptyStateViewDelegate {
    func accountsEmptyStateViewDidTapActionButton(_ accountsEmptyStateView: AccountsEmptyStateView) {
        openWelcomeScreen()
    }

    private func openWelcomeScreen() {
        open(
            .welcome(flow: .addNewAccount(mode: .none)),
            by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
        )
    }
}

extension AccountsViewController: TooltipPresenter {
    func presentQRTooltipIfNeeded() {
        guard let isAccountQRTooltipDisplayed = session?.isAccountQRTooltipDisplayed(),
            isViewAppeared,
            !isAccountQRTooltipDisplayed else {
            return
        }
 
        guard let headerView = accountsView.accountsCollectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)
        ) as? AccountHeaderSupplementaryView else {
            return
        }
        
        presentTooltip(with: "accounts-qr-tooltip".localized, using: configuration, at: headerView.contextView.qrButton)
        session?.setAccountQRTooltipDisplayed()
    }
    
    func adaptivePresentationStyle(
        for controller: UIPresentationController,
        traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension AccountsViewController: APIListener {
    func api(
        _ api: API,
        networkMonitor: NetworkMonitor,
        didConnectVia connection: NetworkConnection,
        from oldConnection: NetworkConnection
    ) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
    
    func api(_ api: API, networkMonitor: NetworkMonitor, didDisconnectFrom oldConnection: NetworkConnection) {
        if UIApplication.shared.isActive {
            isConnectedToInternet = networkMonitor.isConnected
        }
    }
}

extension AccountsViewController {
    struct LayoutConstants: AdaptiveLayoutConstants {
        let optionsModalHeight: CGFloat = 462.0
        let removeAccountModalHeight: CGFloat = 402.0
        let editAccountModalHeight: CGFloat = 158.0
        let passphraseModalHeight: CGFloat = 510.0
        let termsAndServiceHeight: CGFloat = 300
    }
}

struct PasscodeSettingDisplayStore: Storable {
    typealias Object = Any

    let appOpenCountToAskPasscode = 5

    private let appOpenCountKey = "com.algorand.algorand.passcode.app.count.key"
    private let dontAskAgainKey = "com.algorand.algorand.passcode.dont.ask.again"

    var appOpenCount: Int {
        return userDefaults.integer(forKey: appOpenCountKey)
    }

    mutating func increaseAppOpenCount() {
        userDefaults.set(appOpenCount + 1, forKey: appOpenCountKey)
    }

    var hasPermissionToAskAgain: Bool {
        return !userDefaults.bool(forKey: dontAskAgainKey)
    }

    mutating func disableAskingPasscode() {
        userDefaults.set(true, forKey: dontAskAgainKey)
    }

    var shouldAskForPasscode: Bool {
        return appOpenCount % appOpenCountToAskPasscode == 0
    }
}
