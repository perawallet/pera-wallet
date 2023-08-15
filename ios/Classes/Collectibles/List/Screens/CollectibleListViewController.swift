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

    private lazy var listView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeListLayout(galleryUIStyle)
    )

    private lazy var listLayout = CollectibleListLayout(listDataSource: listDataSource, galleryUIStyle: galleryUIStyle)
    private lazy var listDataSource = CollectibleListDataSource(listView)

    private var positionYForDisplayingListHeader: CGFloat?

    private var query: CollectibleListQuery
    private let dataController: CollectibleListDataController
    private let copyToClipboardController: CopyToClipboardController

    private let theme: CollectibleListViewControllerTheme

    private var galleryUIStyleCache: CollectibleGalleryUIStyleCache
    
    var galleryUIStyle: CollectibleGalleryUIStyle {
        didSet { performUpdatesWhenGalleryUIStyleDidChange(old: oldValue) }
    }

    init(
        query: CollectibleListQuery,
        dataController: CollectibleListDataController,
        copyToClipboardController: CopyToClipboardController,
        theme: CollectibleListViewControllerTheme = .common,
        galleryUIStyleCache: CollectibleGalleryUIStyleCache,
        configuration: ViewControllerConfiguration
    ) {
        self.query = query
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController
        self.theme = theme
        self.galleryUIStyleCache = galleryUIStyleCache
        self.galleryUIStyle = galleryUIStyleCache.galleryUIStyle
        self.dataController.galleryUIStyle = galleryUIStyleCache.galleryUIStyle

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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.layoutIfNeeded()

        let imageWidth = listLayout.calculateGridItemCellWidth(
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
            case .didUpdate(let update):
                self.eventHandler?(.didUpdateSnapshot)

                self.listDataSource.apply(
                    update.snapshot,
                    animatingDifferences: self.isViewAppeared
                )
            case .didFinishRunning(let hasError):
                self.eventHandler?(.didFinishRunning(hasError: hasError))
            }
        }

        dataController.load(query: query)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startAnimatingLoadingIfNeededWhenViewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateListLayoutIfNeededWhenViewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }

    private func build() {
        addListView()
    }
}

extension CollectibleListViewController {
    func reloadData(_ filters: CollectibleFilterOptions?) {
        query.update(withFilters: filters)
        dataController.load(query: query)
    }

    private func reloadData(_ order: CollectibleSortingAlgorithm?) {
        query.update(withSort: order)
        dataController.load(query: query)
    }
}

extension CollectibleListViewController {
    private func updateListLayoutIfNeededWhenViewDidAppear() {
        if isViewFirstAppeared { return }

        galleryUIStyle = galleryUIStyleCache.galleryUIStyle

        updateGalleryUIActionsCellIfNeeded()
    }
}

extension CollectibleListViewController {
    private func performUpdatesWhenGalleryUIStyleDidChange(old: CollectibleGalleryUIStyle) {
        if galleryUIStyle == old { return }

        dataController.stopUpdates()

        listLayout.galleryUIStyle = galleryUIStyle
        dataController.galleryUIStyle = galleryUIStyle
        listView.setCollectionViewLayout(
            makeListLayout(galleryUIStyle),
            animated: true
        )

        dataController.startUpdates()
        
        dataController.load(galleryUIStyle: galleryUIStyle)

        galleryUIStyleCache.galleryUIStyle = galleryUIStyle
    }
}

extension CollectibleListViewController {
    private func updateGalleryUIActionsCellIfNeeded() {
        if let indexPath = listDataSource.indexPath(for: .uiActions),
           let cell = listView.cellForItem(at: indexPath) as? CollectibleGalleryUIActionsCell {
            if galleryUIStyle.isGrid {
                cell.setGridUIStyleSelected()
            } else {
                cell.setListUIStyleSelected()
            }
        }
    }
}

extension CollectibleListViewController {
    private func makeListLayout(_ galleryUIStyle: CollectibleGalleryUIStyle) -> UICollectionViewLayout {
        if galleryUIStyle.isGrid {
            return CollectibleListLayout.gridFlowLayout
        } else {
            return CollectibleListLayout.listFlowLayout
        }
    }
}

extension CollectibleListViewController {
    private func startAnimatingLoadingIfNeededWhenViewWillAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let pendingCollectibleGridItemCell = cell as? PendingCollectibleGridItemCell {
                pendingCollectibleGridItemCell.startLoading()
                return
            }

            if let pendingCollectibleListItemCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleListItemCell.startLoading()
                return
            }

            if let gridLoadingCell = cell as? CollectibleGalleryGridLoadingCell {
                gridLoadingCell.startAnimating()
                return
            }

            if let listLoadingCell = cell as? CollectibleGalleryListLoadingCell {
                listLoadingCell.startAnimating()
                return
            }
        }
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let pendingCollectibleGridItemCell = cell as? PendingCollectibleGridItemCell {
                pendingCollectibleGridItemCell.stopLoading()
                return
            }

            if let pendingCollectibleListItemCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleListItemCell.stopLoading()
                return
            }


            if let gridLoadingCell = cell as? CollectibleGalleryGridLoadingCell {
                gridLoadingCell.stopAnimating()
                return
            }

            if let listLoadingCell = cell as? CollectibleGalleryListLoadingCell {
                listLoadingCell.stopAnimating()
                return
            }
        }
    }
}

extension CollectibleListViewController {
    private func addListView() {
        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.keyboardDismissMode = .onDrag
        listView.contentInset.bottom = theme.listContentBottomInset
        listView.backgroundColor = .clear

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
        case .uiActions:
            linkInteractors(cell as! CollectibleGalleryUIActionsCell)
        case .empty(let item):
            switch item {
            case .noContent:
                linkInteractors(cell as! NoContentWithActionIllustratedCell)
            default:
                break
            }
        case .pendingCollectibleAsset(let item):
            switch item {
            case .grid:
                startAnimatingGridItemLoadingIfNeeded(cell as? PendingCollectibleGridItemCell)
            case .list:
                startAnimatingListItemLoadingIfNeeded(cell as? PendingCollectibleAssetListItemCell)
            }
        case .collectibleAssetsLoading(let item):
            switch item {
            case .grid:
                startAnimatingGridLoadingIfNeeded(cell as? CollectibleGalleryGridLoadingCell)
            case .list:
                startAnimatingListLoadingIfNeeded(cell as? CollectibleGalleryListLoadingCell)
            }
        default: break
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
        case .pendingCollectibleAsset(let item):
            switch item {
            case .grid:
                stopAnimatingGridItemLoadingIfNeeded(cell as? PendingCollectibleGridItemCell)
            case .list:
                stopAnimatingListItemLoadingIfNeeded(cell as? PendingCollectibleAssetListItemCell)
            }
        case .collectibleAssetsLoading(let item):
            switch item {
            case .grid:
                stopAnimatingGridLoadingIfNeeded(cell as? CollectibleGalleryGridLoadingCell)
            case .list:
                stopAnimatingListLoadingIfNeeded(cell as? CollectibleGalleryListLoadingCell)
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
        case .collectibleAsset(let item):
            var currentImage: UIImage?

            if let gridItemCell = collectionView.cellForItem(at: indexPath) as? CollectibleGridItemCell {
                currentImage = gridItemCell.contextView.currentImage
            } else if let listItemCell = collectionView.cellForItem(at: indexPath) as? CollectibleListItemCell {
                currentImage = listItemCell.contextView.currentImage
            }

            openCollectibleDetail(
                account: item.account,
                asset: item.asset,
                thumbnailImage: currentImage
            )
        default:
            break
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let asset = getCollectibleAsset(at: indexPath) else {
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
        case .collectibleAsset(let item):
            switch item {
            case .grid:
                let cell = collectionView.cellForItem(at: indexPath) as! CollectibleGridItemCell
                return cell.getTargetedPreview()
            case .list:
                let cell = collectionView.cellForItem(at: indexPath) as! CollectibleListItemCell
                return cell.getTargetedPreview()
            }
        default:
            return nil
        }
    }
}

extension CollectibleListViewController {
    private func startAnimatingListItemLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingListItemLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.stopLoading()
    }
}

extension CollectibleListViewController {
    private func startAnimatingGridItemLoadingIfNeeded(_ cell: PendingCollectibleGridItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingGridItemLoadingIfNeeded(_ cell: PendingCollectibleGridItemCell?) {
        cell?.stopLoading()
    }
}

extension CollectibleListViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: CollectibleGalleryListLoadingCell?) {
        cell?.startAnimating()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: CollectibleGalleryListLoadingCell?) {
        cell?.stopAnimating()
    }
}

extension CollectibleListViewController {
    private func startAnimatingGridLoadingIfNeeded(_ cell: CollectibleGalleryGridLoadingCell?) {
        cell?.startAnimating()
    }

    private func stopAnimatingGridLoadingIfNeeded(_ cell: CollectibleGalleryGridLoadingCell?) {
        cell?.stopAnimating()
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
            self.dataController.galleryAccount.singleAccount?.value.authorization.isWatch ?? false
            
            if isWatchAccount {
                self.clearFilters()
                return
            }
            
            self.openReceiveCollectibleAccountList()
        }
        
        cell.startObserving(event: .performSecondaryAction) {
            [weak self] in
            guard let self = self else {
                return
            }
            self.clearFilters()
        }
    }
    
    private func clearFilters() {
        var filters = CollectibleFilterOptions()
        filters.displayWatchAccountCollectibleAssetsInCollectibleList = true
        filters.displayOptedInCollectibleAssetsInCollectibleList = true

        reloadData(filters)
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
        _ cell: CollectibleGalleryUIActionsCell
    ) {
        cell.delegate = self

        if galleryUIStyle.isGrid {
            cell.setGridUIStyleSelected()
        } else {
            cell.setListUIStyleSelected()
        }
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
            thumbnailImage: thumbnailImage
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

extension CollectibleListViewController: CollectibleGalleryUIActionsCellDelegate {
    func collectibleGalleryUIActionsViewDidSelectGridUIStyle(_ cell: CollectibleGalleryUIActionsCell) {
        galleryUIStyle = .grid
    }

    func collectibleGalleryUIActionsViewDidSelectListUIStyle(_ cell: CollectibleGalleryUIActionsCell) {
        galleryUIStyle = .list
    }

    func collectibleGalleryUIActionsViewDidEditSearchInput(_ cell: CollectibleGalleryUIActionsCell, input: String?) {
        query.keyword = input
        dataController.load(query: query)
    }

    func collectibleGalleryUIActionsViewDidReturnSearchInput(_ cell: CollectibleGalleryUIActionsCell) {
        cell.endEditing()
    }
}

extension CollectibleListViewController: ManagementOptionsViewControllerDelegate {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        let eventHandler: SortCollectibleListViewController.EventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didComplete:
                let order = self.sharedDataController.selectedCollectibleSortingAlgorithm
                self.reloadData(order)
            }

            self.dismiss(animated: true)
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

    func managementOptionsViewControllerDidTapFilterCollectibles(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {
        eventHandler?(.didTapFilter)
    }

    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
    
    func managementOptionsViewControllerDidTapFilterAssets(
        _ managementOptionsViewController: ManagementOptionsViewController
    ) {}
}

extension CollectibleListViewController {
    private func getCollectibleAsset(
        at indexPath: IndexPath
    ) -> CollectibleAsset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        if case CollectibleListItem.collectibleAsset(let item) = itemIdentifier {
            return item.asset
        }

        return nil
    }
}

extension CollectibleListViewController {
    enum Event {
        case didUpdateSnapshot
        case didTapReceive
        case willDisplayListHeader
        case didEndDisplayingListHeader
        case didFinishRunning(hasError: Bool)
        case didTapFilter
    }
}
