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
//   HomeViewController.swift

import Foundation
import UIKit
import MacaroonUtils
import MacaroonUIKit

final class HomeViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)
    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var pushNotificationController =
        PushNotificationController(session: session!, api: api!, bannerController: bannerController)
    
    private let onceWhenViewDidAppear = Once()

    override var name: AnalyticsScreenName? {
        return .accounts
    }

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = HomeListLayout.build()
        let collectionView =
        UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = HomeListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = HomeListDataSource(listView)

    /// <todo>: Refactor
    /// This is needed for ChoosePasswordViewControllerDelegate's method.
    private var selectedAccountHandle: AccountHandle? = nil
    private var sendTransactionDraft: SendTransactionDraft?
    
    private var isViewFirstAppeared = true
    
    private let dataController: HomeDataController
    
    init(
        dataController: HomeDataController,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        addBarButtons()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            switch event {
            case .didUpdate(let snapshot):
                self.configureWalletConnectIfNeeded()
                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            }
        }
        dataController.load()

        pushNotificationController.requestAuthorization()
        pushNotificationController.sendDeviceDetails()

        requestAppReview()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.restartAnimating()

        if isViewFirstAppeared {
            presentPeraIntroductionIfNeeded()
            presentPasscodeFlowIfNeeded()
            isViewFirstAppeared = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let loadingCell = listView.visibleCells.first { $0 is HomeLoadingCell } as? HomeLoadingCell
        loadingCell?.stopAnimating()
    }

    override func customizeTabBarAppearence() {
        tabBarHidden = false
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
    }
}

extension HomeViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addBarButtons() {
        let notificationBarButtonItem = ALGBarButtonItem(kind: .notification) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(.notifications, by: .push)
        }

        let qrBarButtonItem = ALGBarButtonItem(kind: .qr) { [weak self] in
            guard let self = self else {
                return
            }

            let qrScannerViewController = self.open(.qrScanner(canReadWCSession: true), by: .push) as? QRScannerViewController
            qrScannerViewController?.delegate = self
        }

        let addBarButtonItem = ALGBarButtonItem(kind: .circleAdd) { [weak self] in
            guard let self = self else {
                return
            }

            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            )
        }

        leftBarButtonItems = [notificationBarButtonItem]
        rightBarButtonItems = [addBarButtonItem, qrBarButtonItem]
    }
}

extension HomeViewController {
    private func linkInteractors(
        _ cell: HomeNoContentCell
    ) {
        cell.observe(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            
            self.open(
                .welcome(flow: .addNewAccount(mode: .none)),
                by: .customPresent(
                    presentationStyle: .fullScreen,
                    transitionStyle: nil,
                    transitioningDelegate: nil
                )
            )
        }
    }
    
    private func linkInteractors(
        _ cell: HomePortfolioCell,
        for item: HomePortfolioViewModel
    ) {
        cell.observe(event: .showInfo) {
            [weak self] in
            guard let self = self else { return }
            
            /// <todo>
            /// How to manage it without knowing view controller. Name conventions vs. protocols???
            let eventHandler: PortfolioCalculationInfoViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }

                switch event {
                case .close:
                    self.dismiss(animated: true)
                }
            }

            self.modalTransition.perform(
                .portfolioCalculationInfo(
                    result: item.totalValueResult,
                    eventHandler: eventHandler
                ),
                by: .presentWithoutNavigationController
            )
        }

        cell.observe(event: .buyAlgo) {
            [weak self] in
            guard let self = self else { return }

            self.launchBuyAlgo()
        }
    }
    
    private func linkInteractors(
        _ cell: TitleWithAccessorySupplementaryCell,
        for item: HomeAccountSectionHeaderViewModel
    ) {
        cell.observe(event: .performAccessory) {
            [weak self] in
            guard let self = self else { return }
            
            let eventHandler: AccountListOptionsViewController.EventHandler = {
                [weak self] event in
                guard let self = self else { return }
                
                self.dismiss(animated: true) {
                    [weak self] in
                    guard let self = self else { return }
                    
                    switch event {
                    case .addAccount:
                        self.open(
                            .welcome(flow: .addNewAccount(mode: .none)),
                            by: .customPresent(
                                presentationStyle: .fullScreen,
                                transitionStyle: nil,
                                transitioningDelegate: nil
                            )
                        )
                    case .arrangeAccounts(let accountType):
                        let eventHandler: OrderAccountListViewController.EventHandler = {
                            [weak self] event in
                            guard let self = self else { return }
                            
                            self.dismiss(animated: true) {
                                [weak self] in
                                guard let self = self else { return }
                                
                                switch event {
                                case .didReorder: self.dataController.reload()
                                }
                            }
                        }
                        self.open(
                            .orderAccountList(accountType: accountType, eventHandler: eventHandler),
                            by: .present
                        )
                    }
                }
            }
            
            self.modalTransition.perform(
                .accountListOptions(accountType: item.type, eventHandler: eventHandler),
                by: .presentWithoutNavigationController
            )
        }
    }
}

extension HomeViewController {
    private func requestAppReview() {
        asyncMain(afterDuration: 1.0) {
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
                .tutorial(flow: .none, tutorial: .passcode),
                by: .customPresent(presentationStyle: .fullScreen, transitionStyle: nil, transitioningDelegate: nil)
            ) as? TutorialViewController
            controller?.uiHandlers.didTapSecondaryActionButton = { tutorialViewController in
                tutorialViewController.dismissScreen()
            }
            controller?.uiHandlers.didTapDontAskAgain = { tutorialViewController in
                tutorialViewController.dismissScreen()
                passcodeSettingDisplayStore.disableAskingPasscode()
            }
        }
    }

    private func presentPeraIntroductionIfNeeded() {
        var peraAppLaunchStore = PeraAppLaunchStore()
        
        let appLaunchStore = ALGAppLaunchStore()

        if appLaunchStore.isOnboarding {
            peraAppLaunchStore.isOnboarded = true
            return
        }

        if peraAppLaunchStore.isOnboarded {
            return
        }
        
        peraAppLaunchStore.isOnboarded = true

        open(.peraIntroduction, by: .present)
    }
}

extension HomeViewController {
    private func configureWalletConnectIfNeeded() {
        onceWhenViewDidAppear.execute { [weak self] in
            guard let self = self else {
                return
            }

            self.completeWalletConnectConfiguration()
        }
    }

    private func completeWalletConnectConfiguration() {
        reconnectToOldWCSessions()
        registerWCRequests()
    }

    private func reconnectToOldWCSessions() {
        walletConnector.reconnectToSavedSessionsIfPossible()
    }

    private func registerWCRequests() {
        let wcRequestHandler = TransactionSignRequestHandler()
        if let rootViewController = UIApplication.shared.rootViewController() {
            wcRequestHandler.delegate = rootViewController
        }
        walletConnector.register(for: wcRequestHandler)
    }
}

extension HomeViewController {
    private func presentOptions(for accountHandle: AccountHandle) {
        modalTransition.perform(
            .invalidAccount(
                account: accountHandle,
                uiInteractionsHandler: linkInvalidAccountOptionsUIInteractions(
                    accountHandle
                )
            )
            ,
            by: .presentWithoutNavigationController
        )
    }
}

extension HomeViewController: QRScannerViewControllerDelegate {
    func qrScannerViewController(_ controller: QRScannerViewController, didRead qrText: QRText, completionHandler: EmptyHandler?) {
        switch qrText.mode {
        case .address:
            open(.addContact(address: qrText.address, name: qrText.label), by: .push)
        case .algosRequest:
            guard let address = qrText.address,
                  let amount = qrText.amount else {
                      return
                  }

            let toAccount = Account(address: address, type: .standard)

            var draft = SendTransactionDraft(from: toAccount, transactionMode: .algo)
            draft.note = qrText.lockedNote
            draft.lockedNote = qrText.lockedNote
            draft.amount = amount.toAlgos

            self.sendTransactionDraft = draft

            open(
                .accountSelection(transactionAction: .send, delegate: self),
                by: .present
            )

            return
        case .assetRequest:
            guard let address = qrText.address,
                  let amount = qrText.amount,
                  let assetId = qrText.asset else {
                      return
                  }

            var asset: AssetInformation?

            for accountHandle in sharedDataController.accountCollection.sorted() {
                for compoundAsset in accountHandle.value.compoundAssets where compoundAsset.id == assetId {
                    asset = compoundAsset.detail
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
                    actionTitle: "title-approve".localized,
                    cancelTitle: "title-cancel".localized
                )

                modalTransition.perform(
                    .assetActionConfirmation(assetAlertDraft: assetAlertDraft, delegate: nil),
                    by: .presentWithoutNavigationController
                )
                return
            }

            let toAccount = Account(address: address, type: .standard)
            var draft = SendTransactionDraft(from: toAccount, transactionMode: .assetDetail(assetDetail))
            draft.amount = Decimal(amount)
            draft.note = qrText.lockedNote
            draft.lockedNote = qrText.lockedNote

            self.sendTransactionDraft = draft

            open(
                .accountSelection(transactionAction: .send, delegate: self),
                by: .present
            )

            return
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

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            sizeForItemAt: indexPath
        )
    }
}

extension HomeViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! HomeNoContentCell)
            }
        case .portfolio(let item):
            linkInteractors(
                cell as! HomePortfolioCell,
                for: item
            )
        case .account(let item):
            switch item {
            case .header(let headerItem):
                linkInteractors(
                    cell as! TitleWithAccessorySupplementaryCell,
                    for: headerItem
                )
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? HomeLoadingCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        switch itemIdentifier {
        case .account(let item):
            switch item {
            case .cell(let cellItem):
                guard let account = dataController[cellItem.address] else {
                    return
                }

                self.selectedAccountHandle = account
                
                if account.isAvailable {
                    let eventHandler: AccountDetailViewController.EventHandler = {
                        [weak self] event in
                        guard let self = self else { return }
                        
                        switch event {
                        case .didRemove:
                            self.popScreen()
                            self.dataController.reload()
                        }
                    }
                    open(
                        .accountDetail(accountHandle: account, eventHandler: eventHandler),
                        by: .push
                    )
                } else {
                    presentOptions(for: account)
                }
            default:
                break
            }
        default: break
        }
    }
}

extension HomeViewController: SelectAccountViewControllerDelegate {
    func selectAccountViewController(
        _ selectAccountViewController: SelectAccountViewController,
        didSelect account: Account,
        for transactionAction: TransactionAction
    ) {
        guard transactionAction == .send, let draft = sendTransactionDraft else {
            return
        }

        var transactionDraft = SendTransactionDraft(
            from: account,
            toAccount: draft.from,
            amount: draft.amount,
            transactionMode: draft.transactionMode
        )
        transactionDraft.note = draft.lockedNote
        transactionDraft.lockedNote = draft.lockedNote

        selectAccountViewController.open(.sendTransaction(draft: transactionDraft), by: .push)
    }
}

extension HomeViewController: ChoosePasswordViewControllerDelegate {
    func linkInvalidAccountOptionsUIInteractions(_ accountHandle: AccountHandle) -> InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions {
        var uiInteractions = InvalidAccountOptionsViewController.InvalidAccountOptionsUIInteractions()

        uiInteractions.didTapShowQRCode = {
            [weak self] in

            guard let self = self else {
                return
            }

            let draft = QRCreationDraft(
                address: accountHandle.value.address,
                mode: .address,
                title: accountHandle.value.name
            )
            self.open(
                .qrGenerator(
                    title: accountHandle.value.name ?? accountHandle.value.address.shortAddressDisplay(),
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
        }

        uiInteractions.didTapViewPassphrase = {
            [weak self] in

            guard let self = self else {
                return
            }

            guard let session = self.session else {
                return
            }

            if !session.hasPassword() {
                self.presentPassphraseView(accountHandle)
                return
            }

            let localAuthenticator = LocalAuthenticator()

            if localAuthenticator.localAuthenticationStatus != .allowed {
                let controller = self.open(
                    .choosePassword(
                        mode: .confirm(flow: .viewPassphrase),
                        flow: nil
                    ),
                    by: .present
                ) as? ChoosePasswordViewController
                controller?.delegate = self
                return
            }

            localAuthenticator.authenticate {
                [weak self] error in

                guard let self = self,
                      error == nil else {
                          return
                      }

                self.presentPassphraseView(accountHandle)
            }
        }

        uiInteractions.didTapCopyAddress = {
            [weak self] in

            guard let self = self else {
                return
            }

            self.log(ReceiveCopyEvent(address: accountHandle.value.address))
            UIPasteboard.general.string = accountHandle.value.address
            self.bannerController?.presentInfoBanner("qr-creation-copied".localized)
        }

        return uiInteractions
    }

    func choosePasswordViewController(
        _ choosePasswordViewController: ChoosePasswordViewController,
        didConfirmPassword isConfirmed: Bool
    ) {
        choosePasswordViewController.dismissScreen()
        
        guard let selectedAccountHandle = selectedAccountHandle else {
            return
        }

        if isConfirmed {
            presentPassphraseView(selectedAccountHandle)
        }
    }

    private func presentPassphraseView(_ accountHandle: AccountHandle) {
        modalTransition.perform(
            .passphraseDisplay(address: accountHandle.value.address),
            by: .present
        )
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
