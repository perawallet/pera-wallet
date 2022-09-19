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

//   CollectibleListViewController.swift

import UIKit
import MacaroonUIKit

final class CollectibleListViewController:
    BaseViewController,
    UICollectionViewDelegateFlowLayout {
    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var modalTransition = BottomSheetTransition(presentingViewController: self)

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = CollectibleListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.contentInset.bottom = theme.listContentBottomInset
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var listLayout = CollectibleListLayout(listDataSource: listDataSource)
    private lazy var listDataSource = CollectibleListDataSource(listView)

    private var positionYForDisplayingListHeader: CGFloat?

    private let dataController: CollectibleListDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme: CollectibleListViewControllerTheme

    init(
        dataController: CollectibleListDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: CollectibleListViewControllerTheme = .common,
        configuration: ViewControllerConfiguration
    ) {
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func prepareLayout() {
        super.prepareLayout()
        build()
    }

    override func setListeners() {
        super.setListeners()

        listView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        listView
            .visibleCells
            .forEach { cell in
                switch cell {
                case is CollectibleListLoadingViewCell:
                    let loadingCell = cell as? CollectibleListLoadingViewCell
                    loadingCell?.restartAnimating()
                default:
                    break
                }
            }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        listView
            .visibleCells
            .forEach { cell in
                switch cell {
                case is CollectibleListLoadingViewCell:
                    let loadingCell = cell as? CollectibleListLoadingViewCell
                    loadingCell?.stopAnimating()
                default:
                    break
                }
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()

        let imageWidth = listLayout.calculateGridCellWidth(
            listView,
            layout: listView.collectionViewLayout
        )
        let imageSize = CGSize((imageWidth, imageWidth))
        dataController.imageSize = imageSize

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else {
                return
            }

            switch event {
            case .didUpdate(let snapshot):
                var accounts: [AccountHandle] = []

                switch self.dataController.galleryAccount {
                case .single(let account):
                    guard let account = self.sharedDataController.accountCollection[account.value.address] else {
                        return
                    }

                    accounts = [account]
                case .all:
                    accounts = self.sharedDataController.sortedAccounts()
                }

                self.eventHandler?(.didUpdate(accounts))

                self.listDataSource.apply(snapshot, animatingDifferences: self.isViewAppeared)
            case .didFinishRunning(let hasError):
                self.eventHandler?(.didFinishRunning(hasError: hasError))
            }
        }

        dataController.load()
    }

    private func build() {
        addListView()
    }
}

extension CollectibleListViewController {
    private func addListView() {
        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.setPaddings()
        }
    }
}

extension CollectibleListViewController {
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

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        switch itemIdentifier {
        case .header:
            positionYForDisplayingListHeader = cell.frame.maxY
            linkInteractors(cell as! ManagementItemWithSecondaryActionCell)
        case .watchAccountHeader:
            linkInteractors(cell as! ManagementItemCell)
        case .search:
            linkInteractors(cell as! CollectibleListSearchInputCell)
        case .empty(let item):
            switch item {
            case .loading:
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.startAnimating()
            case .noContent:
                linkInteractors(cell as! NoContentWithActionIllustratedCell)
            default:
                break
            }
        case .collectible(let item):
            switch item {
            case .cell(let item):
                linkInteractors(cell, item: item)
            }
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
                let loadingCell = cell as? CollectibleListLoadingViewCell
                loadingCell?.stopAnimating()
            default:
                break
            }
        default:
            break
        }
    }
}

extension CollectibleListViewController {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        endEditing()

        switch itemIdentifier {
        case .collectible(let item):
            switch item {
            case .cell(let cell):
                switch cell {
                case .pending: break
                case .owner(let item):
                    let cell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemCell
                    openCollectibleDetail(
                        account: item.account,
                        asset: item.asset,
                        thumbnailImage: cell?.contextView.currentImage
                    )
                case .optedIn(let item):
                    let cell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemOptedInCell
                    openCollectibleDetail(
                        account: item.account,
                        asset: item.asset,
                        thumbnailImage: cell?.contextView.currentImage
                    )
                }
            }
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let asset = getCollectibleItem(at: indexPath)?.asset else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath
        ) { _ in
            let copyActionItem = UIAction(item: .copyAssetID) {
                [unowned self] _ in
                self.copyToClipboardController.copyID(asset)
            }
            return UIMenu(children: [ copyActionItem ])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(
            collectionView,
            configuration: configuration
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(
            collectionView,
            configuration: configuration
        )
    }

    private func makeTargetedPreview(
        _ collectionView: UICollectionView,
        configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let itemIdentifier = listDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        switch itemIdentifier {
        case .collectible(let item):
            switch item {
            case .cell(let cell):
                switch cell {
                case .pending,
                     .owner:
                    let cell = collectionView.cellForItem(at: indexPath) as! CollectibleListItemCell
                    return cell.getTargetedPreview()
                case .optedIn:
                    let cell = collectionView.cellForItem(at: indexPath) as! CollectibleListItemOptedInCell
                    return cell.getTargetedPreview()
                }
            }
        default:
            return nil
        }
    }
}

/// <mark>
/// UIScrollViewDelegate
extension CollectibleListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let positionY = positionYForDisplayingListHeader else { return }

        let currentContentOffset = listView.contentOffset
        let isDisplayingListHeader = currentContentOffset.y < positionY
        let event: Event = isDisplayingListHeader ? .willDisplayListHeader : .didEndDisplayingListHeader
        eventHandler?(event)
    }
}

extension CollectibleListViewController {
    private func linkInteractors(
        _ cell: NoContentWithActionIllustratedCell
    ) {
        cell.startObserving(event: .performPrimaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            let isWatchAccount =
            self.dataController.galleryAccount.singleAccount?.value.isWatchAccount() ?? false

            if isWatchAccount {
                self.dataController.filter(
                    by: .all
                )

                return
            }

            self.openReceiveCollectibleAccountList()
        }

        cell.startObserving(event: .performSecondaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.dataController.filter(
                by: .all
            )
        }
    }

    private func linkInteractors(
        _ cell: ManagementItemWithSecondaryActionCell
    ) {
        cell.startObserving(event: .primaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()
            
            self.openCollectiblesManagementScreen()
        }

        cell.startObserving(event: .secondaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()

            self.openReceiveCollectibleAccountList()
        }
    }

    private func linkInteractors(
        _ cell: ManagementItemCell
    ) {
        cell.startObserving(event: .primaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }

            self.endEditing()

            self.openCollectiblesManagementScreen()
        }
    }

    private func linkInteractors(
        _ cell: CollectibleListSearchInputCell
    ) {
        cell.delegate = self
    }

    private func linkInteractors(
        _ cell: UICollectionViewCell,
        item: CollectibleCellItem
    ) {
        cell.isUserInteractionEnabled = !item.isPending
    }
}

extension CollectibleListViewController {
    private func openCollectibleDetail(
        account: Account,
        asset: CollectibleAsset,
        thumbnailImage: UIImage?
    ) {
        let screen = Screen.collectibleDetail(
            asset: asset,
            account: account,
            thumbnailImage: thumbnailImage,
            quickAction: nil
        ) { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didOptOutAssetFromAccount: self.popScreen()
            case .didOptOutFromAssetWithQuickAction: break
            case .didOptInToAsset: break
            }
        }

        open(
            screen,
            by: .push
        )
    }

    private func openReceiveCollectibleAccountList() {
        eventHandler?(.didTapReceive)
    }

    private func openCollectiblesManagementScreen() {
        modalTransition.perform(
            .managementOptions(
                managementType: .collectibles,
                delegate: self
            ),
            by: .present
        )
    }
}

extension CollectibleListViewController: SearchInputViewDelegate {
    func searchInputViewDidEdit(_ view: SearchInputView) {
        guard let query = view.text else {
            return
        }

        if query.isEmpty {
            dataController.resetSearch()
            return
        }

        dataController.search(for: query)
    }

    func searchInputViewDidReturn(_ view: SearchInputView) {
        view.endEditing()
    }
}

extension CollectibleListViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortCollectibleListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                [weak self] in
                guard let self = self else { return }

                switch event {
                case .didComplete: self.dataController.reload()
                }
            }
        }

        open(
            .sortCollectibleList(
                dataController: SortCollectibleListLocalDataController(
                    session: session!,
                    sharedDataController: sharedDataController
                ),
                eventHandler: eventHandler
            ),
            by: .present
        )
    }

    func managementOptionsViewControllerDidTapFilter(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let controller = open(
            .collectiblesFilterSelection(
                filter: dataController.currentFilter
            ),
            by: .present
        ) as? CollectiblesFilterSelectionViewController

        controller?.handlers.didChangeFilter = {
            [weak self] filter in
            guard let self = self else {
                return
            }

            self.dataController.filter(
                by: filter
            )
        }
    }

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
}

extension CollectibleListViewController {
    private func getCollectibleItem(
        at indexPath: IndexPath
    ) -> CollectibleCellItemContainer<CollectibleListItemViewModel>? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        switch itemIdentifier {
        case .collectible(let collectibleItem):
            switch collectibleItem {
            case .cell(let collectibleCellItem):
                switch collectibleCellItem {
                case .owner(let item),
                     .optedIn(let item),
                     .pending(let item):
                    return item
                }
            }
        default:
            return nil
        }
    }
}

extension CollectibleListViewController {
    enum Event {
        case didUpdate([AccountHandle])
        case didTapReceive
        case willDisplayListHeader
        case didEndDisplayingListHeader
        case didFinishRunning(hasError: Bool)
    }
}
