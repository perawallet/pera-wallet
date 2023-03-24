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
//   AccountAssetListViewController.swift

import Foundation
import MacaroonForm
import MacaroonUIKit
import MacaroonUtils
import UIKit

final class AccountAssetListViewController:
    BaseViewController,
    SearchBarItemCellDelegate,
    MacaroonForm.KeyboardControllerDataSource,
    NotificationObserver {
    var notificationObservations: [NSObjectProtocol] = []

    typealias EventHandler = (Event) -> Void

    var eventHandler: EventHandler?

    private lazy var theme = Theme()

    private lazy var listLayout = AccountAssetListLayout(
        isWatchAccount: dataController.account.value.isWatchAccount(),
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AccountAssetListDataSource(listView)

    private lazy var transitionToMinimumBalanceInfo = BottomSheetTransition(presentingViewController: self)

    private lazy var listView: UICollectionView = {
        let collectionViewLayout = AccountAssetListLayout.build()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = theme.listBackgroundColor.uiColor
        collectionView.keyboardDismissMode = .interactive
        return collectionView
    }()
    private lazy var listBackgroundView = UIView()

    private lazy var keyboardController = MacaroonForm.KeyboardController(
        scrollView: listView,
        screen: self
    )

    private lazy var accountActionsMenuActionView = FloatingActionItemButton(hasTitleLabel: false)
    private var positionYForVisibleAccountActionsMenuAction: CGFloat?

    private var query: AccountAssetListQuery

    private let dataController: AccountAssetListDataController

    private let copyToClipboardController: CopyToClipboardController

    init(
        query: AccountAssetListQuery,
        dataController: AccountAssetListDataController,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.query = query
        self.dataController = dataController
        self.copyToClipboardController = copyToClipboardController

        super.init(configuration: configuration)

        keyboardController.activate()
    }

    deinit {
        keyboardController.deactivate()

        stopObservingNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.eventHandler = {
            [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdate(let updates):
                self.eventHandler?(.didUpdate(self.dataController.account))

                switch updates.operation {
                case .customize:
                    self.listView.scrollToTop(animated: false)
                case .search:
                    let bottom = self.listView.contentSize.height
                    let minBottom = self.calculateMinEmptySpacingToScrollSearchInputFieldToTop()
                    self.listView.contentInset.bottom = max(bottom, minBottom)
                case .refresh:
                    break
                }

                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                ) { [weak self] in
                    guard let self else { return }

                    if updates.operation == .search {
                        self.keyboardController.scrollToEditingRect(
                            afterContentDidChange: true,
                            animated: false
                        )
                    }
                }
            }
        }
        dataController.load(query: query)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !listView.frame.isEmpty {
            updateUIWhenViewDidLayoutSubviews()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startAnimatingLoadingIfNeededWhenViewDidAppear()

        if !isViewFirstAppeared {
            reloadIfNeededForPendingAssetRequests()
        }

        analytics.track(.recordAccountDetailScreen(type: .tapAssets))
    }

    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()

        startAnimatingLoadingIfNeededWhenViewDidAppear()
        reloadIfNeededForPendingAssetRequests()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimatingLoadingIfNeededWhenViewDidDisappear()
    }

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()
        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()

        listView.delegate = self

        observeWhenUserIsOnboardedToSwap()
    }

    func reloadData(_ filters: AssetFilterOptions?) {
        query.update(withFilters: filters)
        dataController.load(query: query)
    }

    func reloadData(_ order: AccountAssetSortingAlgorithm?) {
        query.update(withSort: order)
        dataController.load(query: query)
    }

    private func reloadIfNeededForPendingAssetRequests() {
        dataController.reloadIfNeededForPendingAssetRequests()
    }
}

extension AccountAssetListViewController {
    private func addUI() {
        addListBackground()
        addList()

        if !dataController.account.value.isWatchAccount() {
            addAccountActionsMenuAction()
            updateSafeAreaWhenViewDidLayoutSubviews()
        }
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateListWhenViewDidLayoutSubviews()
        updateListBackgroundWhenViewDidLayoutSubviews()
        updateAccountActionsMenuActionWhenViewDidLayoutSubviews()
        updateSafeAreaWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenListDidScroll() {
        updateListBackgroundWhenListDidScroll()
        updateAccountActionsMenuActionWhenListDidScroll()
        updateSafeAreaWhenListDidScroll()
    }

    private func addListBackground() {
        listBackgroundView.customizeAppearance(
            [
                .backgroundColor(Colors.Helpers.heroBackground)
            ]
        )

        view.addSubview(listBackgroundView)
        listBackgroundView.snp.makeConstraints {
            $0.fitToHeight(0)
            $0.top == 0
            $0.leading == 0
            $0.trailing == 0
        }
    }

    private func updateListBackgroundWhenListDidScroll() {
        updateListBackgroundWhenViewDidLayoutSubviews()
    }

    private func updateListBackgroundWhenViewDidLayoutSubviews() {
        /// <note>
        /// 150/250 is a number smaller than the total height of the total portfolio and the quick
        /// actions menu cells, and big enough to cover the background area when the system
        /// triggers auto-scrolling to the top because of the applying snapshot (The system just
        /// does it if the user pulls down the list extending the bounds of the content even if
        /// there isn't anything to update.)
        let thresholdHeight: CGFloat = dataController.account.value.isWatchAccount() ? 150 : 250
        let preferredHeight: CGFloat = thresholdHeight - listView.contentOffset.y

        listBackgroundView.snp.updateConstraints {
            $0.fitToHeight(max(preferredHeight, 0))
        }
    }

    private func addList() {
        listView.customizeAppearance(
            [
                .backgroundColor(UIColor.clear)
            ]
        )

        view.addSubview(listView)
        listView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        listView.showsVerticalScrollIndicator = false
        listView.showsHorizontalScrollIndicator = false
        listView.alwaysBounceVertical = true
        listView.delegate = self
    }

    private func updateListWhenViewDidLayoutSubviews() {
        if keyboardController.isKeyboardVisible {
            return
        }

        let bottom = bottomInsetWhenKeyboardDidHide(keyboardController)
        listView.setContentInset(bottom: bottom)
    }

    private func updateSafeAreaWhenListDidScroll() {
        updateSafeAreaWhenViewDidLayoutSubviews()
    }

    private func updateSafeAreaWhenViewDidLayoutSubviews() {
        if keyboardController.isKeyboardVisible {
            return
        }

        if !canAccessAccountActionsMenu() {
            additionalSafeAreaInsets.bottom = 0
            return
        }

        let listSafeAreaBottom =
            theme.spacingBetweenListAndAccountActionsMenuAction +
            theme.accountActionsMenuActionSize.h +
            theme.accountActionsMenuActionBottomPadding
        additionalSafeAreaInsets.bottom = listSafeAreaBottom
    }
}

extension AccountAssetListViewController {
    private func addAccountActionsMenuAction() {
        accountActionsMenuActionView.image = theme.accountActionsMenuActionIcon

        view.addSubview(accountActionsMenuActionView)

        accountActionsMenuActionView.snp.makeConstraints {
            let safeAreaBottom = view.compactSafeAreaInsets.bottom
            let bottom = safeAreaBottom + theme.accountActionsMenuActionBottomPadding

            $0.fitToSize(theme.accountActionsMenuActionSize)
            $0.trailing == theme.accountActionsMenuActionTrailingPadding
            $0.bottom == bottom
        }

        accountActionsMenuActionView.addTouch(
            target: self,
            action: #selector(openAccountActionsMenu)
        )

        updateAccountActionsMenuActionWhenViewDidLayoutSubviews()
    }

    private func updateAccountActionsMenuActionWhenListDidScroll() {
        updateAccountActionsMenuActionWhenViewDidLayoutSubviews()
    }

    private func updateAccountActionsMenuActionWhenViewDidLayoutSubviews() {
        accountActionsMenuActionView.isHidden = keyboardController.isKeyboardVisible || !canAccessAccountActionsMenu()
    }

    @objc
    private func openAccountActionsMenu() {
        eventHandler?(.transactionOption)
    }

    private func canAccessAccountActionsMenu() -> Bool {
        guard let positionY = positionYForVisibleAccountActionsMenuAction else {
            return false
        }

        let listHeight = listView.bounds.height
        let listContentHeight = listView.contentSize.height

        if listContentHeight - listHeight <= positionY {
            return false
        }

        let listContentOffset = listView.contentOffset
        return listContentOffset.y >= positionY
    }
}

extension AccountAssetListViewController {
    private func startAnimatingLoadingIfNeededWhenViewDidAppear() {
        if isViewFirstAppeared { return }

        for cell in listView.visibleCells {
            if let pendingAssetCell = cell as? PendingAssetListItemCell {
                pendingAssetCell.startLoading()
                return
            }

            if let pendingCollectibleAssetCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleAssetCell.startLoading()
                return
            }

            if let assetLoadingCell = cell as? AccountAssetListLoadingCell {
                assetLoadingCell.startAnimating()
                return
            }
        }
    }

    private func stopAnimatingLoadingIfNeededWhenViewDidDisappear() {
        for cell in listView.visibleCells {
            if let pendingAssetCell = cell as? PendingAssetListItemCell {
                pendingAssetCell.stopLoading()
                return
            }

            if let pendingCollectibleAssetCell = cell as? PendingCollectibleAssetListItemCell {
                pendingCollectibleAssetCell.stopLoading()
                return
            }

            if let assetLoadingCell = cell as? AccountAssetListLoadingCell {
                assetLoadingCell.stopAnimating()
                return
            }
        }
    }
}

extension AccountAssetListViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateUIWhenListDidScroll()
    }
}

extension AccountAssetListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers
        
        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }
        
        switch listSection {
        case .portfolio:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .portfolio:
                let cell = cell as! AccountPortfolioCell
                cell.startObserving(event: .showMinimumBalanceInfo) {
                    [unowned self] in
                    openMinimumBalanceInfo()
                }
            default:
                break
            }
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }
            
            switch itemIdentifier {
            case .assetManagement:
                guard let item = cell as? ManagementItemWithSecondaryActionCell else {
                    return
                }
                
                item.startObserving(event: .primaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(
                        .manageAssets(
                            isWatchAccount: false
                        )
                    )
                }
                item.startObserving(event: .secondaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.addAsset)
                }
            case .watchAccountAssetManagement:
                let item = cell as! ManagementItemCell

                item.startObserving(event: .primaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }

                    self.eventHandler?(
                        .manageAssets(
                            isWatchAccount: true
                        )
                    )
                }
            case .search:
                let itemCell = cell as? SearchBarItemCell
                itemCell?.delegate = self
            case .assetLoading:
                startAnimatingListLoadingIfNeeded(cell)
            case .pendingAsset:
                startAnimatingListLoadingIfNeeded(cell as? PendingAssetListItemCell)
            case .pendingCollectibleAsset:
                startAnimatingListLoadingIfNeeded(cell as? PendingCollectibleAssetListItemCell)
            default:
                return
            }
        case .quickActions:
            guard let item = cell as? AccountQuickActionsCell else {
                return
            }

            let swapDisplayStore = SwapDisplayStore()
            let isOnboardedToSwap = swapDisplayStore.isOnboardedToSwap
            item.isSwapBadgeVisible = !isOnboardedToSwap

            positionYForVisibleAccountActionsMenuAction = cell.frame.maxY

            item.startObserving(event: .buySell) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.buySell)
            }

            item.startObserving(event: .swap) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.swap)
            }

            item.startObserving(event: .send) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.send)
            }

            item.startObserving(event: .more) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.more)
            }
        default:
            return
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }

        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .assetLoading:
                stopAnimatingListLoadingIfNeeded(cell)
            case .pendingAsset:
                stopAnimatingListLoadingIfNeeded(cell as? PendingAssetListItemCell)
            case .pendingCollectibleAsset:
                stopAnimatingListLoadingIfNeeded(cell as? PendingCollectibleAssetListItemCell)
            default:
                break
            }
        default:
            break
        }
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
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return listLayout.collectionView(
            collectionView,
            layout: collectionViewLayout,
            insetForSectionAt: section
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionIdentifiers = listDataSource.snapshot().sectionIdentifiers

        guard let listSection = sectionIdentifiers[safe: indexPath.section] else {
            return
        }

        switch listSection {
        case .assets:
            guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
                return
            }

            switch itemIdentifier {
            case .asset(let item):
                /// <todo>
                /// Normally, we should handle account error or asset error here even if it is
                /// impossible to have an error. Either we should refactor the flow, or we should
                /// handle the errors.
                let screen = Screen.asaDetail(
                    account: dataController.account.value,
                    asset: item.asset
                ) { [weak self] event in
                    guard let self = self else { return }

                    switch event {
                    case .didRenameAccount: self.eventHandler?(.didRenameAccount)
                    case .didRemoveAccount: self.eventHandler?(.didRemoveAccount)
                    }
                }
                open(
                    screen,
                    by: .push
                )
            case .collectibleAsset(let item):
                let screen = Screen.collectibleDetail(
                    asset: item.asset,
                    account: dataController.account.value,
                    thumbnailImage: nil,
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
            default:
                break
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
        guard let asset = getAsset(at: indexPath) else {
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
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = collectionView.cellForItem(at: indexPath)
        else {
            return nil
        }

        return UITargetedPreview(
            view: cell,
            backgroundColor: Colors.Defaults.background.uiColor
        )
    }
}

extension AccountAssetListViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: PendingAssetListItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: PendingAssetListItemCell?) {
        cell?.stopLoading()
    }
}

extension AccountAssetListViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? AccountAssetListLoadingCell
        loadingCell?.startAnimating()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: UICollectionViewCell) {
        let loadingCell = cell as? AccountAssetListLoadingCell
        loadingCell?.stopAnimating()
    }
}

extension AccountAssetListViewController {
    private func startAnimatingListLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.startLoading()
    }

    private func stopAnimatingListLoadingIfNeeded(_ cell: PendingCollectibleAssetListItemCell?) {
        cell?.stopLoading()
    }
}

extension AccountAssetListViewController {
    private func openMinimumBalanceInfo() {
        let uiSheet = UISheet(
            title: "minimum-balance-title".localized.bodyLargeMedium(),
            body: "minimum-balance-description".localized.bodyRegular()
        )

        let closeAction = UISheetAction(
            title: "title-close".localized,
            style: .cancel
        ) { [unowned self] in
            self.dismiss(animated: true)
        }
        uiSheet.addAction(closeAction)

        transitionToMinimumBalanceInfo.perform(
            .sheetAction(sheet: uiSheet),
            by: .presentWithoutNavigationController
        )
    }

    private func observeWhenUserIsOnboardedToSwap() {
        observe(notification: SwapDisplayStore.isOnboardedToSwapNotification) {
            [weak self] _ in
            guard let self = self else { return }

            guard
                let indexPath = self.listDataSource.indexPath(for: .quickActions),
                let cell = self.listView.cellForItem(at: indexPath) as? AccountQuickActionsCell
            else {
                return
            }

            cell.isSwapBadgeVisible = false
        }
    }
}

/// <mark>
/// SearchBarItemCellDelegate
extension AccountAssetListViewController {
    func searchBarItemCellDidBeginEditing(
        _ cell: SearchBarItemCell
    ) {}

    func searchBarItemCellDidEdit(
        _ cell: SearchBarItemCell
    ) {
        /// <note>
        /// First, the search input field will be scrolled to the top, then we will make adjustments
        /// to the scroll state after the searched data is loaded.
        keyboardController.scrollToEditingRect(
            afterContentDidChange: false,
            animated: true
        )

        query.keyword = cell.input
        dataController.load(query: query)
    }

    func searchBarItemCellDidTapRightAccessory(
        _ cell: SearchBarItemCell
    ) {}

    func searchBarItemCellDidReturn(
        _ cell: SearchBarItemCell
    ) {
        cell.endEditing()
    }

    func searchBarItemCellDidEndEditing(
        _ cell: SearchBarItemCell
    ) {}
}

extension AccountAssetListViewController {
    private func getAsset(
        at indexPath: IndexPath
    ) -> Asset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        if case AccountAssetsItem.asset(let item) = itemIdentifier {
            return item.asset
        }

        if case AccountAssetsItem.collectibleAsset(let item) = itemIdentifier {
            return item.asset
        }

        return nil
    }
}

/// <mark>
/// MacaroonForm.KeyboardControllerDataSource
extension AccountAssetListViewController {
    func keyboardController(
        _ keyboardController: MacaroonForm.KeyboardController,
        editingRectIn view: UIView
    ) -> CGRect? {
        return getEditingRectOfSearchInputField()
    }

    func bottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return 0
    }

    func additionalBottomInsetOverKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateEmptySpacingToScrollSearchInputFieldToTop()
    }

    func bottomInsetUnderKeyboardWhenKeyboardDidShow(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return 0
    }

    func bottomInsetWhenKeyboardDidHide(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        /// <note>
        /// It doesn't scroll to the bottom during the transition to another screen. When the
        /// screen is back, it will show the keyboard again anyway.
        if isViewDisappearing {
            return listView.contentInset.bottom
        }

        return 0
    }

    func spacingBetweenEditingRectAndKeyboard(
        _ keyboardController: MacaroonForm.KeyboardController
    ) -> LayoutMetric {
        return calculateSpacingToScrollSearchInputFieldToTop()
    }
}

extension AccountAssetListViewController {
    private func calculateEmptySpacingToScrollSearchInputFieldToTop() -> CGFloat {
        guard let editingRectOfSearchInputField = getEditingRectOfSearchInputField() else {
            return 0
        }

        let editingOriginYOfSearchInputField = editingRectOfSearchInputField.minY
        let visibleHeight = view.bounds.height
        let minContentHeight =
            editingOriginYOfSearchInputField +
            visibleHeight
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        let contentHeight = listView.contentSize.height
        let maybeEmptySpacing =
            minContentHeight -
            contentHeight -
            keyboardHeight
        return max(maybeEmptySpacing, 0)
    }

    private func calculateMinEmptySpacingToScrollSearchInputFieldToTop() -> CGFloat {
        let visibleHeight = view.bounds.height
        let editingRectOfSearchInputField = getEditingRectOfSearchInputField()
        let editingHeightOfSearchInputField = editingRectOfSearchInputField?.height ?? 0
        return visibleHeight - editingHeightOfSearchInputField
    }

    private func calculateSpacingToScrollSearchInputFieldToTop() -> CGFloat {
        guard let editingRectOfSearchInputField = getEditingRectOfSearchInputField() else {
            return theme.minSpacingBetweenSearchInputFieldAndKeyboard
        }

        let visibleHeight = view.bounds.height
        let editingHeightOfSearchInputField = editingRectOfSearchInputField.height
        let keyboardHeight = keyboardController.keyboard?.height ?? 0
        return
            visibleHeight -
            editingHeightOfSearchInputField -
            keyboardHeight
    }
}

extension AccountAssetListViewController {
    private func getEditingRectOfSearchInputField() -> CGRect? {
        let indexPathOfSearchInputField = listDataSource.indexPath(for: AccountAssetsItem.search)

        guard
            let indexPath = indexPathOfSearchInputField,
            let attributes = listView.layoutAttributesForItem(at: indexPath)
        else {
            return nil
        }

        return attributes.frame
    }
}

extension AccountAssetListViewController {
    enum Event {
        case didUpdate(AccountHandle)
        case didRenameAccount
        case didRemoveAccount
        case manageAssets(isWatchAccount: Bool)
        case addAsset
        case buySell
        case swap
        case send
        case more
        case transactionOption
    }
}
