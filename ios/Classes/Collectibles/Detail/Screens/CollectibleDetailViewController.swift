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

//   CollectibleDetailViewController.swift

import UIKit
import MacaroonUIKit
import MacaroonURLImage

final class CollectibleDetailViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout,
    TransactionControllerDelegate {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var bottomBannerController = BottomActionableBannerController(
        presentingView: view,
        configuration: BottomActionableBannerControllerConfiguration(
            bottomMargin: 0,
            contentBottomPadding: view.safeAreaBottom + 20
        )
    )

    private lazy var transactionController: TransactionController = {
        guard let api = api else {
            fatalError("API should be set.")
        }

        return TransactionController(
            api: api,
            sharedDataController: sharedDataController,
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var transitionToOptOutAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToLedgerConnection = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )
    private lazy var transitionToLedgerConnectionIssuesWarning = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToSignWithLedgerProcess = BottomSheetTransition(
        presentingViewController: self,
        interactable: false
    )

    private lazy var collectibleDetailTransactionController = CollectibleDetailTransactionController(
        account: account,
        asset: asset,
        transactionController: transactionController,
        sharedDataController: sharedDataController
    )

    private var ledgerConnectionScreen: LedgerConnectionScreen?
    private var signWithLedgerProcessScreen: SignWithLedgerProcessScreen?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleDetailLayout.build()
        collectionViewLayout.sectionIdentifierProvider = {
            [unowned self] section in
            self.dataSource.snapshot().sectionIdentifiers[safe: section]
        }
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var assetQuickActionView = AssetQuickActionView()

    private lazy var listLayout = CollectibleDetailLayout(
        dataSource: dataSource,
        collectibleDescriptionProvider: {
            [weak self] in
            guard let self else { return nil }
            return self.collectibleDescriptionViewModel
        }
    )
    private lazy var dataSource = CollectibleDetailDataSource(
        collectionView: listView,
        mediaPreviewController: mediaPreviewController,
        collectibleDescriptionProvider: {
            [weak self] in
            guard let self else { return nil }
            return self.collectibleDescriptionViewModel
        }
    )

    private lazy var mediaPreviewController = CollectibleMediaPreviewViewController(
        asset: asset,
        accountCollectibleStatus: dataController.getCurrentAccountCollectibleStatus(),
        thumbnailImage: thumbnailImage,
        configuration: configuration
    )

    private lazy var currencyFormatter = CurrencyFormatter()

    private lazy var collectibleDescriptionViewModel = CollectibleDescriptionViewModel(asset: asset, isTruncated: true)

    private var asset: CollectibleAsset
    private var account: Account
    private let quickAction: AssetQuickAction?
    private let thumbnailImage: UIImage?
    private let dataController: CollectibleDetailDataController
    private let copyToClipboardController: CopyToClipboardController

    private var displayedMedia: Media?

    init(
        asset: CollectibleAsset,
        account: Account,
        quickAction: AssetQuickAction?,
        thumbnailImage: UIImage?,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.account = account
        self.quickAction = quickAction
        self.thumbnailImage = thumbnailImage
        self.dataController = CollectibleDetailAPIDataController(
            api: configuration.api!,
            asset: asset,
            account: account,
            quickAction: quickAction,
            sharedDataController: configuration.sharedDataController
        )
        self.copyToClipboardController = copyToClipboardController
        super.init(configuration: configuration)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let snapshot):
                self.dataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
                self.updateMediaPreview()
            case .didFetch(let asset):
                self.asset = asset
                self.displayedMedia = asset.media.first
                self.mediaPreviewController.updateAsset(asset)
            case .didResponseFail(let message):
                self.bottomBannerController.presentFetchError(
                    title: "title-generic-api-error".localized,
                    message: "title-error-description".localized(message),
                    actionTitle: "title-retry".localized,
                    actionHandler: {
                        [unowned self] in
                        self.bottomBannerController.dismissError()
                        self.dataController.load()
                    }
                )
            }
        }

        view.backgroundColor = Colors.Defaults.background.uiColor

        dataController.load()

        addChild(mediaPreviewController)
        mediaPreviewController.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.bounds.isEmpty { return }

        if quickAction != nil && assetQuickActionView.isDescendant(of: self.view) {
            /// <note>
            /// The safe area of the view will equal to the one it set as
            /// `additionalSafeAreaInsets.bottom` next time this method is called.
            let safeAreaBottom = view.window?.safeAreaInsets.bottom ?? 0
            let bottom = assetQuickActionView.bounds.height - safeAreaBottom
            additionalSafeAreaInsets.bottom = bottom
        } else {
            additionalSafeAreaInsets.bottom = 0
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }

    override func configureNavigationBarAppearance() {
        super.configureNavigationBarAppearance()

        addBarButtons()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addListView()
        addAssetQuickActionIfNeeded()
    }

    override func setListeners() {
        super.setListeners()
        listView.delegate = self
        transactionController.delegate = self

        collectibleDetailTransactionController.eventHandlers.didStartRemovingAsset = {
            [weak self] in
            guard let self = self else { return }

            self.loadingController?.startLoadingWithMessage("title-loading".localized)

            if self.account.requiresLedgerConnection() {
                self.openLedgerConnection()
            }
        }

        collectibleDetailTransactionController.eventHandlers.didStartOptingInToAsset = {
            [weak self] in
            guard let self = self else { return }

            self.loadingController?.startLoadingWithMessage("title-loading".localized)

            if self.account.requiresLedgerConnection() {
                self.openLedgerConnection()
            }
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkMediaPreviewInteractors()
    }
}

extension CollectibleDetailViewController {
    private func addBarButtons() {
        let shareBarButtonItem = ALGBarButtonItem(kind: .share) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.shareCollectible()
        }

        rightBarButtonItems = [shareBarButtonItem]
    }
}

extension CollectibleDetailViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }

    private func addAssetQuickActionIfNeeded() {
        guard let quickAction = quickAction else { return }
        
        let accountCollectibleStatus = dataController.getCurrentAccountCollectibleStatus()

        switch quickAction {
        case .optIn:
            if accountCollectibleStatus == .notOptedIn {
                addAssetQuickAction()
                bindAssetOptInQuickAction()
            }
        case .optOut:
            if accountCollectibleStatus == .optedIn {
                addAssetQuickAction()
                bindAssetOptOutAction()
            }
        }
    }

    private func addAssetQuickAction() {
        assetQuickActionView.customize(AssetQuickActionViewTheme())

        view.addSubview(assetQuickActionView)
        assetQuickActionView.snp.makeConstraints {
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }
    }

    private func bindAssetOptInQuickAction() {
        let viewModel = AssetQuickActionViewModel(
            asset: asset,
            type: .optIn(with: account)
        )
        assetQuickActionView.bindData(viewModel)

        assetQuickActionView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }
            self.linkAssetQuickActionViewInteractors()
        }
    }

    private func bindAssetOptOutAction() {
        let viewModel = AssetQuickActionViewModel(
            asset: asset,
            type: .optOut(from: account)
        )
        assetQuickActionView.bindData(viewModel)

        assetQuickActionView.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            self.openOptOutAssetIfPossible()
        }
    }

    private func removeQuickAction() {
        assetQuickActionView.removeFromSuperview()
    }
    
    private func updateMediaPreview() {
        let accountCollectibleStatus = dataController.getCurrentAccountCollectibleStatus()
        mediaPreviewController.updateAccountCollectibleStatus(accountCollectibleStatus)
    }
}

extension CollectibleDetailViewController {
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
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumLineSpacingForSectionAt: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            minimumInteritemSpacingForSectionAt: section
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForHeaderInSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? CollectibleDetailLoadingCell
            loadingCell?.startAnimating()
        case .accountInformation:
            linkInteractors(
                cell as! CollectibleDetailAccountInformationCell
            )
        case .sendAction:
            linkInteractors(
                cell as! CollectibleDetailSendActionCell
            )
        case .optOutAction:
            linkInteractors(
                cell as! CollectibleDetailOptOutActionCell
            )
        case .information(let item):
            if item.actionURL != nil {
                linkInteractors(
                    cell as! CollectibleDetailInformationCell,
                    for: item
                )
            }
        case .creatorAccount:
            linkInteractors(cell as! CollectibleDetailCreatorAccountItemCell)
        case .assetID:
            linkInteractors(cell as! CollectibleDetailAssetIDItemCell)
        case .description:
            linkInteractors(cell as! CollectibleDescriptionCell )
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .loading:
            let loadingCell = cell as? CollectibleDetailLoadingCell
            loadingCell?.stopAnimating()
        default: break
        }
    }
}

extension CollectibleDetailViewController {
    private func linkMediaPreviewInteractors() {
        mediaPreviewController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didScrollToMedia(let media):
                self.displayedMedia = media
            }
        }
    }
    private func linkInteractors(
        _ cell: CollectibleDetailAccountInformationCell
    ) {
        cell.startObserving(event: .didLongPressTitle) {
            [unowned self] in
            self.copyToClipboardController.copyAddress(account)
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailSendActionCell
    ) {
        cell.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self,
                  let asset = self.account[self.asset.id] as? CollectibleAsset else {
                return
            }
            
            var assetAmount: Decimal?
            if asset.isPure {
                assetAmount = 1
            }
            
            let draft = SendTransactionDraft(
                from: self.account,
                amount: assetAmount,
                transactionMode: .asset(asset)
            )

            let controller = self.open(
                .sendTransaction(draft: draft),
                by: .present
            ) as? SendTransactionScreen

            controller?.eventHandler = {
                [weak self] event in
                guard let self = self else { return }
                switch event {
                case .didCompleteTransaction:
                    self.popScreen()
                }
            }
        }
    }

    private func shareCollectible() {
        var items: [Any] = []

        if let explorerURL = asset.explorerURL {
            items.append(explorerURL.absoluteString)
        } else if let downloadURL = displayedMedia?.downloadURL {
            items.append(downloadURL.absoluteString)
        }

        presentShareController(items)
    }

    private func presentShareController(
        _ items: [Any]
    ) {
        open(
            .shareActivity(
                items: items
            ),
            by: .presentWithoutNavigationController
        )
    }

    private func linkInteractors(
        _ cell: CollectibleDetailOptOutActionCell
    ) {
        cell.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            self.openOptOutAssetIfPossible()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailInformationCell,
        for item: CollectibleTransactionInformation
    ) {
        cell.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self,
                  let actionURL = item.actionURL else {
                return
            }

            self.open(actionURL)
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailCreatorAccountItemCell
    ) {
        cell.startObserving(event: .didTapAccessory) {
            [unowned self] in
            let creator = self.asset.creator!.address
            let source = AlgoExplorerExternalSource(
                address: creator,
                network: self.api!.network
            )
            self.open(source.url)
        }

        cell.startObserving(event: .didLongPressAccessory) {
            [unowned self] in
            let creator = self.asset.creator!.address
            self.copyToClipboardController.copyAddress(creator)
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailAssetIDItemCell
    ) {
        cell.startObserving(event: .didTapAccessory) {
            [unowned self] in

            let optInStatus = self.dataController.hasOptedIn()

            if optInStatus == .rejected {
                self.openASADiscovery()
                return
            }

            self.openASADetail()
        }

        cell.startObserving(event: .didLongPressAccessory) {
            [unowned self] in
            self.copyToClipboardController.copyID(self.asset)
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDescriptionCell
    ) {
        cell.delegate = self
    }

    private func openASADiscovery() {
        let screen = Screen.asaDiscovery(
            account: account,
            quickAction: nil,
            asset: AssetDecoration(asset: asset)
        )

        open(
            screen,
            by: .push
        )
    }

    private func openASADetail() {
        let configuration = ASADetailScreenConfiguration(
            shouldDisplayAccountActionsBarButtonItem: false,
            shouldDisplayQuickActions: false
        )
        let screen = Screen.asaDetail(
            account: account,
            asset: asset,
            configuration: configuration
        )
        open(
            screen,
            by: .push
        )
    }
}

extension CollectibleDetailViewController {
    private func openOptOutAssetIfPossible() {
        if account.authorization.isNoAuth {
            presentActionsNotAvailableForAccountBanner()
            return
        }

        let draft = OptOutAssetDraft(
            account: account,
            asset: asset
        )

        let screen = Screen.optOutAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove: self.continueToOptOutAsset()
            case .performClose: self.cancelOptOutAsset()
            }
        }

        transitionToOptOutAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptOutAsset() {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            self.collectibleDetailTransactionController.optOutAsset()
        }
    }

    private func cancelOptOutAsset() {
        dismiss(animated: true)
    }
}

extension CollectibleDetailViewController {
    private func presentActionsNotAvailableForAccountBanner() {
        bannerController?.presentErrorBanner(
            title: "action-not-available-for-account-type".localized,
            message: ""
        )
    }
}

extension CollectibleDetailViewController {
    private func linkAssetQuickActionViewInteractors() {
        let assetDecoration = AssetDecoration(asset: asset)
        let draft = OptInAssetDraft(
            account: account,
            asset: assetDecoration
        )
        let screen = Screen.optInAsset(draft: draft) {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performApprove: self.continueToOptInAsset(asset: assetDecoration)
            case .performClose: self.cancelOptInAsset()
            }
        }
        transitionToOptInAsset.perform(
            screen,
            by: .present
        )
    }

    private func continueToOptInAsset(
        asset: AssetDecoration
    ) {
        dismiss(animated: true) {
            [weak self] in
            guard let self = self else { return }

            self.collectibleDetailTransactionController.optInToAsset()
        }
    }

    private func cancelOptInAsset() {
        dismiss(animated: true)
    }
}

extension CollectibleDetailViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

        if let quickAction = quickAction {
            switch quickAction {
            case .optIn:
                removeQuickAction()
                dataController.reloadAfterOptInStatusUpdates()

                NotificationCenter.default.post(
                    name: CollectibleListLocalDataController.didAddCollectible,
                    object: self
                )
                
                eventHandler?(.didOptInToAsset)
            case .optOut:
                removeQuickAction()
                dataController.reloadAfterOptInStatusUpdates()

                NotificationCenter.default.post(
                    name: CollectibleListLocalDataController.didRemoveCollectible,
                    object: self
                )

                eventHandler?(.didOptOutFromAssetWithQuickAction)
            }
            return
        }

        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didRemoveCollectible,
            object: self
        )

        eventHandler?(.didOptOutAssetFromAccount)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()

        switch error {
        case let .inapp(transactionError):
            displayTransactionError(from: transactionError)
        default:
            break
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedTransaction error: HIPTransactionError
    ) {
        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()

        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: apiError.debugDescription
            )
        default:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.localizedDescription
            )
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        ledgerConnectionScreen?.dismiss(animated: true) {
            self.ledgerConnectionScreen = nil

            self.openSignWithLedgerProcess(
                transactionController: transactionController,
                ledgerDeviceName: ledger
            )
        }
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerConnectionScreen?.dismissScreen()
        ledgerConnectionScreen = nil

        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        cancelMonitoringOptInOutUpdates(for: transactionController)

        loadingController?.stopLoading()
    }

    func transactionControllerDidResetLedgerOperationOnSuccess(_ transactionController: TransactionController) {
        signWithLedgerProcessScreen?.dismissScreen()
        signWithLedgerProcessScreen = nil

        loadingController?.stopLoading()
    }

    private func cancelMonitoringOptInOutUpdates(for transactionController: TransactionController) {
        if let transactionType = transactionController.currentTransactionType {
            let monitor = sharedDataController.blockchainUpdatesMonitor
            switch transactionType {
            case .assetAddition:
                monitor.cancelMonitoringOptInUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            case .assetRemoval:
                monitor.cancelMonitoringOptOutUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            default:
                break
            }
        }
    }
}

extension CollectibleDetailViewController {
    private func openLedgerConnection() {
        let eventHandler: LedgerConnectionScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .performCancel:
                self.transactionController.stopBLEScan()
                self.transactionController.stopTimer()
                self.cancelMonitoringOptInOutUpdates(for: self.transactionController)

                self.ledgerConnectionScreen?.dismissScreen()
                self.ledgerConnectionScreen = nil

                self.loadingController?.stopLoading()
            }
        }

        ledgerConnectionScreen = transitionToLedgerConnection.perform(
            .ledgerConnection(eventHandler: eventHandler),
            by: .presentWithoutNavigationController
        )
    }
}

extension CollectibleDetailViewController {
    private func openLedgerConnectionIssues() {
        transitionToLedgerConnectionIssuesWarning.perform(
            .bottomWarning(
                configurator: BottomWarningViewConfigurator(
                    image: "icon-info-green".uiImage,
                    title: "ledger-pairing-issue-error-title".localized,
                    description: .plain("ble-error-fail-ble-connection-repairing".localized),
                    secondaryActionButtonTitle: "title-ok".localized
                )
            ),
            by: .presentWithoutNavigationController
        )
    }
}

extension CollectibleDetailViewController {
    private func openSignWithLedgerProcess(
        transactionController: TransactionController,
        ledgerDeviceName: String
    ) {
        let draft = SignWithLedgerProcessDraft(
            ledgerDeviceName: ledgerDeviceName,
            totalTransactionCount: 1
        )
        let eventHandler: SignWithLedgerProcessScreen.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .performCancelApproval:
                transactionController.stopBLEScan()
                transactionController.stopTimer()

                self.signWithLedgerProcessScreen?.dismissScreen()
                self.signWithLedgerProcessScreen = nil

                self.cancelMonitoringOptInOutUpdates(for: transactionController)

                self.loadingController?.stopLoading()
            }
        }
        signWithLedgerProcessScreen = transitionToSignWithLedgerProcess.perform(
            .signWithLedgerProcess(
                draft: draft,
                eventHandler: eventHandler
            ),
            by: .present
        ) as? SignWithLedgerProcessScreen
    }
}

extension CollectibleDetailViewController {
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            currencyFormatter.formattingContext = .standalone()
            currencyFormatter.currency = AlgoLocalCurrency()

            let amountText = currencyFormatter.format(amount.toAlgos)

            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amountText.someString
                )
            )
        case let .sdkError(error):
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: error.debugDescription
            )
        case .ledgerConnection:
            ledgerConnectionScreen?.dismiss(animated: true) {
                self.openLedgerConnectionIssues()
            }
        case .optOutFromCreator:
            bannerController?.presentErrorBanner(
                title: "title-error".localized,
                message: "asset-creator-opt-out-error-message".localized
            )
        default:
            break
        }
    }
}

extension CollectibleDetailViewController: CollectibleDescriptionCellDelegate {
    func collectibleDescriptionCellDidTapURL(_ cell: CollectibleDescriptionCell, url: URL) {
        open(url)
    }

    func collectibleDescriptionCellDidShowMore(_ cell: CollectibleDescriptionCell) {
        updateCollectibleDescriptionCell(cell, isTruncated: false)
    }

    func collectibleDescriptionCellDidShowLess(_ cell: CollectibleDescriptionCell) {
        updateCollectibleDescriptionCell(cell, isTruncated: true)
    }

    private func updateCollectibleDescriptionCell(_ cell: CollectibleDescriptionCell, isTruncated: Bool) {
        let viewModel = CollectibleDescriptionViewModel(
            asset: asset,
            isTruncated: isTruncated
        )
        collectibleDescriptionViewModel = viewModel

        cell.bindData(viewModel)

        listView.collectionViewLayout.invalidateLayout()
    }
}

extension CollectibleDetailViewController {
    var currentVisibleMediaCell: UICollectionViewCell? {
        return mediaPreviewController.currentVisibleCell
    }
}

extension CollectibleDetailViewController {
    enum Event {
        case didOptOutAssetFromAccount
        case didOptOutFromAssetWithQuickAction
        case didOptInToAsset
    }
}
