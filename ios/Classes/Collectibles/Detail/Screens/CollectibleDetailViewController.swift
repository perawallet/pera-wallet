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

        return TransactionController(api: api, bannerController: bannerController)
    }()

    private lazy var assetActionConfirmationTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var collectibleDetailTransactionController = CollectibleDetailTransactionController(
        account: account,
        asset: asset,
        transactionController: transactionController
    )

    private var ledgerApprovalViewController: LedgerApprovalViewController?

    lazy var eventHandlers = Event()

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

    private var asset: CollectibleAsset
    private let account: Account
    private let thumbnailImage: UIImage?
    private let dataController: CollectibleDetailDataController

    private var displayedMedia: Media?

    init(
        asset: CollectibleAsset,
        account: Account,
        thumbnailImage: UIImage?,
        configuration: ViewControllerConfiguration
    ) {
        self.asset = asset
        self.account = account
        self.thumbnailImage = thumbnailImage
        self.dataController = CollectibleDetailAPIDataController(
            api: configuration.api!,
            asset: asset,
            account: account
        )
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

        view.backgroundColor = AppColors.Shared.System.background.uiColor

        dataController.load()

        addChild(mediaPreviewController)
        mediaPreviewController.didMove(toParent: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        transactionController.stopBLEScan()
        transactionController.stopTimer()
    }

    override func prepareLayout() {
        super.prepareLayout()
        addListView()
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
            default: break
            }
        }
    }

    private func linkInteractors(
        _ cell: CollectibleDetailActionCell,
        for item: CollectibleDetailActionViewModel
    ) {
        cell.observe(event: .performSend) {
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

                let closeBarButtonItem = ALGBarButtonItem(kind: .close) {
                    [weak controller] in
                    controller?.dismissScreen()
                }
                controller?.leftBarButtonItems = [closeBarButtonItem]
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

        cell.observe(event: .performShare) {
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
        cell.observe(event: .performShare) {
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
        cell.observe(event: .performShare) {
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
        cell.observe(event: .performOptOut) {
            [weak self] in
            guard let self = self else {
                return
            }


            let draft = self.collectibleDetailTransactionController.createOptOutAlertDraft()
            self.assetActionConfirmationTransition.perform(
                .assetActionConfirmation(
                    assetAlertDraft: draft,
                    delegate: self.collectibleDetailTransactionController
                ),
                by: .presentWithoutNavigationController
            )
        }

        cell.observe(event: .performCopy) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.bannerController?.presentInfoBanner("qr-creation-copied".localized)
            UIPasteboard.general.string = self.account.address
        }

        cell.observe(event: .performShareQR) {
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
        cell.observe(event: .performAction) {
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
        cell.observe(event: .performAction) {
            [weak self] in
            guard let self = self else { return }

            if let urlString = item.source?.url,
               let url = URL(string: urlString) {
                self.open(url)
            }
        }
    }
}

extension CollectibleDetailViewController {
    func transactionController(
        _ transactionController: TransactionController,
        didComposedTransactionDataFor draft: TransactionSendDraft?
    ) {
        loadingController?.stopLoading()

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

        eventHandlers.didOptOutAssetFromAccount?()
    }

    func transactionController(
        _ transactionController: TransactionController,
        didFailedComposing error: HIPTransactionError
    ) {
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
        loadingController?.stopLoading()
        switch error {
        case let .network(apiError):
            bannerController?.presentErrorBanner(title: "title-error".localized, message: apiError.debugDescription)
        default:
            bannerController?.presentErrorBanner(title: "title-error".localized, message: error.localizedDescription)
        }
    }

    func transactionController(
        _ transactionController: TransactionController,
        didRequestUserApprovalFrom ledger: String
    ) {
        let ledgerApprovalTransition = BottomSheetTransition(presentingViewController: self)
        ledgerApprovalViewController = ledgerApprovalTransition.perform(
            .ledgerApproval(
                mode: .approve,
                deviceName: ledger
            ),
            by: .present
        )
    }

    func transactionControllerDidResetLedgerOperation(
        _ transactionController: TransactionController
    ) {
        ledgerApprovalViewController?.dismissScreen()
        ledgerApprovalViewController = nil
    }
}

extension CollectibleDetailViewController {
    private func displayTransactionError(from transactionError: TransactionError) {
        switch transactionError {
        case let .minimumAmount(amount):
            bannerController?.presentErrorBanner(
                title: "asset-min-transaction-error-title".localized,
                message: "asset-min-transaction-error-message".localized(
                    params: amount.toAlgos.toAlgosStringForLabel ?? ""
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
    struct Event {
        var didOptOutAssetFromAccount: EmptyHandler?
    }
}
