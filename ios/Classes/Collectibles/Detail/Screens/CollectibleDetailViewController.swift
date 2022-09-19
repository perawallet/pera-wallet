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
    TransactionControllerDelegate,
    TransactionSignChecking {
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
            bannerController: bannerController,
            analytics: analytics
        )
    }()

    private lazy var transitionToOptOutAsset = BottomSheetTransition(presentingViewController: self)
    private lazy var transitionToOptInAsset = BottomSheetTransition(presentingViewController: self)

    private lazy var collectibleDetailTransactionController = CollectibleDetailTransactionController(
        account: account,
        asset: asset,
        transactionController: transactionController,
        sharedDataController: sharedDataController
    )

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleDetailLayout.build()
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

    private lazy var listLayout = CollectibleDetailLayout(dataSource: dataSource)
    private lazy var dataSource = CollectibleDetailDataSource(
        collectionView: listView,
        mediaPreviewController: mediaPreviewController
    )

    private lazy var mediaPreviewController = CollectibleMediaPreviewViewController(
        asset: asset,
        thumbnailImage: thumbnailImage,
        configuration: configuration
    )

    private lazy var currencyFormatter = CurrencyFormatter()

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
                        self.dataController.retry()
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
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
        }

        collectibleDetailTransactionController.eventHandlers.didStartOptingInToAsset = {
            [weak self] in
            guard let self = self else { return }

            self.loadingController?.startLoadingWithMessage("title-loading".localized)
        }
    }

    override func linkInteractors() {
        super.linkInteractors()
        linkMediaPreviewInteractors()
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

        switch quickAction {
        case .optIn:
            let optInStatus = dataController.hasOptedIn()

            if optInStatus != .rejected { return }

            addAssetQuickAction()
            bindAssetOptInQuickAction()
        case .optOut:
            let optInStatus = dataController.hasOptedIn()
            let optOutStatus = dataController.hasOptedOut()

            /// <note>
            /// It has already been opted out or not opted in.
            if optOutStatus != .rejected || optInStatus == .rejected {
                return
            }

            addAssetQuickAction()
            bindAssetOptOutAction()
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

            self.openOptOutAsset()
        }
    }

    private func removeQuickAction() {
        assetQuickActionView.removeFromSuperview()
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
        case .action(let item):
            linkInteractors(
                cell as! CollectibleDetailActionCell,
                for: item
            )
        case .watchAccountAction(let item):
            linkInteractors(
                cell as! CollectibleDetailWatchAccountActionCell,
                for: item
            )
        case .collectibleCreatorAccountAction(let item):
            linkInteractors(
                cell as! CollectibleDetailCreatorAccountActionCell,
                for: item
            )
        case .optedInAction(let item):
            linkInteractors(
                cell as! CollectibleDetailOptedInActionCell,
                for: item
            )
        case .information(let item):
            if item.actionURL != nil {
                linkInteractors(
                    cell as! CollectibleDetailInformationCell,
                    for: item
                )
            }
        case .external(let item):
            linkInteractors(
                cell as! CollectibleExternalSourceCell,
                for: item
            )
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
        _ cell: CollectibleDetailActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.startObserving(event: .performSend) {
            [weak self] in
            guard let self = self,
                  let asset = self.account[self.asset.id] as? CollectibleAsset else {
                return
            }

            if !asset.isPure {
                let draft = SendTransactionDraft(
                    from: self.account,
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
                return
            }

            let draft = SendCollectibleDraft(
                fromAccount: self.account,
                collectibleAsset: asset,
                image: self.mediaPreviewController.getExistingImage()
            )

            let controller = self.open(
                .sendCollectible(
                    draft: draft
                ),
                by: .customPresent(
                    presentationStyle: .overCurrentContext,
                    transitionStyle: .crossDissolve,
                    transitioningDelegate: nil
                ),
                animated: false
            ) as? SendCollectibleViewController

            controller?.eventHandler = {
                [weak self, controller] event in
                guard let self = self else { return }
                switch event {
                case .didCompleteTransaction:
                    controller?.dismissScreen(animated: false) {
                        self.popScreen(animated: false)
                    }
                }
            }
        }

        cell.startObserving(event: .performShare) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.shareCollectible()
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
        _ cell: CollectibleDetailWatchAccountActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.startObserving(event: .performShare) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.shareCollectible()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailCreatorAccountActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.startObserving(event: .performShare) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.shareCollectible()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailOptedInActionCell,
        for item: CollectibleDetailOptedInActionViewModel
    ) {
        cell.startObserving(event: .performOptOut) {
            [weak self] in
            guard let self = self else { return }

            self.openOptOutAsset()
        }

        cell.startObserving(event: .performCopy) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.copyToClipboardController.copyAddress(self.account)
            UIPasteboard.general.string = self.account.address
        }

        cell.startObserving(event: .performShareQR) {
            [weak self] in
            guard let self = self else {
                return
            }

            let accountName = self.account.name ?? self.account.address.shortAddressDisplay

            let draft = QRCreationDraft(
                address: self.account.address,
                mode: .address,
                title: accountName
            )

            self.open(
                .qrGenerator(
                    title: accountName,
                    draft: draft,
                    isTrackable: true
                ),
                by: .present
            )
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
        _ cell: CollectibleExternalSourceCell,
        for item: CollectibleExternalSourceViewModel
    ) {
        cell.startObserving(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            if let url = item.source?.url {
                self.open(url)
            }
        }
    }
}

extension CollectibleDetailViewController {
    private func openOptOutAsset() {
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

            if !self.canSignTransaction(for: &self.account) { return }

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

                NotificationCenter.default.post(
                    name: CollectibleListLocalDataController.didAddCollectible,
                    object: self,
                    userInfo: [
                        CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account, asset)
                    ]
                )
                
                eventHandler?(.didOptInToAsset)
            case .optOut:
                removeQuickAction()

                NotificationCenter.default.post(
                    name: CollectibleListLocalDataController.didRemoveCollectible,
                    object: self,
                    userInfo: [
                        CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account, asset)
                    ]
                )

                eventHandler?(.didOptOutFromAssetWithQuickAction)
            }
            return
        }

        bannerController?.presentSuccessBanner(
            title: "collectible-detail-opt-out-success".localized(
                params: asset.title ?? asset.name ?? .empty
            )
        )

        NotificationCenter.default.post(
            name: CollectibleListLocalDataController.didRemoveCollectible,
            object: self,
            userInfo: [
                CollectibleListLocalDataController.accountAssetPairUserInfoKey: (account, asset)
            ]
        )

        eventHandler?(.didOptOutAssetFromAccount)
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
        if let transactionType = transactionController.currentTransactionType {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor

            switch transactionType {
            case .assetAddition:
                monitor.finishMonitoringOptInUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            case .assetRemoval:
                monitor.finishMonitoringOptOutUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            default:
                break
            }
        }

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
        if let transactionType = transactionController.currentTransactionType {
            let monitor = self.sharedDataController.blockchainUpdatesMonitor

            switch transactionType {
            case .assetAddition:
                monitor.finishMonitoringOptInUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            case .assetRemoval:
                monitor.finishMonitoringOptOutUpdates(
                    forAssetID: asset.id,
                    for: account
                )
            default:
                break
            }
        }

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
        let ledgerApprovalTransition = BottomSheetTransition(
            presentingViewController: self,
            interactable: false
        )
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(
                mode: .approve,
                deviceName: ledger
            ),
            by: .present
        )

        ledgerApprovalViewController?.eventHandler = {
            [weak self] event in
            guard let self = self else { return }
            switch event {
            case .didCancel:
                self.ledgerApprovalViewController?.dismissScreen()
                self.loadingController?.stopLoading()
            }
        }
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
        ledgerApprovalViewController = nil
    }

    func transactionControllerDidRejectedLedgerOperation(
        _ transactionController: TransactionController
    ) {
        loadingController?.stopLoading()
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
            let bottomTransition = BottomSheetTransition(presentingViewController: self)

            bottomTransition.perform(
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
        default:
            break
        }
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
