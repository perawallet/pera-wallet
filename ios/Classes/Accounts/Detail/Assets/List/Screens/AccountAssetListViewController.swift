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
        isWatchAccount: accountHandle.value.isWatchAccount(),
        listDataSource: listDataSource
    )

    private lazy var listDataSource = AccountAssetListDataSource(listView)
    private lazy var dataController = AccountAssetListAPIDataController(accountHandle, sharedDataController)

    private lazy var buyAlgoResultTransition = BottomSheetTransition(presentingViewController: self)

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

    private var accountHandle: AccountHandle

    private let copyToClipboardController: CopyToClipboardController

    init(
        accountHandle: AccountHandle,
        copyToClipboardController: CopyToClipboardController,
        configuration: ViewControllerConfiguration
    ) {
        self.accountHandle = accountHandle
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
                let address = self.accountHandle.value.address

                if let accountHandle = self.sharedDataController.accountCollection[address] {
                    self.accountHandle = accountHandle
                    self.eventHandler?(.didUpdate(accountHandle))
                }

                if updates.isNewSearch {
                    let bottom = self.listView.contentSize.height
                    let minBottom = self.calculateMinEmptySpacingToScrollSearchInputFieldToTop()
                    self.listView.contentInset.bottom = max(bottom, minBottom)
                }

                self.listDataSource.apply(
                    updates.snapshot,
                    animatingDifferences: true
                ) {
                    updates.completion?()
                }
            }
        }
        dataController.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !listView.frame.isEmpty {
            updateUIWhenViewDidLayoutSubviews()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        reloadDataIfThereIsPendingUpdates()

        analytics.track(.recordAccountDetailScreen(type: .tapAssets))
    }

    override func viewDidAppearAfterInteractiveDismiss() {
        super.viewDidAppearAfterInteractiveDismiss()
        reloadDataIfThereIsPendingUpdates()
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

    func reloadData() {
        dataController.reload()
    }

    func reloadDataIfThereIsPendingUpdates() {
        if isViewFirstAppeared { return }
        dataController.reloadIfThereIsPendingUpdates()
    }
}

extension AccountAssetListViewController {
    private func addUI() {
        addListBackground()
        addList()

        if !accountHandle.value.isWatchAccount() {
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
        let thresholdHeight: CGFloat = accountHandle.value.isWatchAccount() ? 150 : 250
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

        let currentContentOffset = listView.contentOffset
        return currentContentOffset.y >= positionY
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

            item.startObserving(event: .buyAlgo) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.buyAlgo)
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
                if let asset = item.asset {
                    let screen = Screen.asaDetail(
                        account: accountHandle.value,
                        asset: asset
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
                }
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
        dataController.search(for: cell.input) {
            [weak self] in
            guard let self = self else { return }

            self.keyboardController.scrollToEditingRect(
                afterContentDidChange: true,
                animated: false
            )
        }
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
    ) -> StandardAsset? {
        guard let itemIdentifier = listDataSource.itemIdentifier(for: indexPath) else {
            return nil
        }

        guard case AccountAssetsItem.asset = itemIdentifier else {
            return nil
        }

        return dataController[indexPath.item]
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
        case buyAlgo
        case swap
        case send
        case more
        case transactionOption
    }
}
