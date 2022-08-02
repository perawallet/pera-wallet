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
import UIKit

final class AccountAssetListViewController:
    BaseViewController,
    SearchBarItemCellDelegate,
    MacaroonForm.KeyboardControllerDataSource {
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

    override func prepareLayout() {
        super.prepareLayout()
        
        addUI()
        view.layoutIfNeeded()
    }

    override func linkInteractors() {
        super.linkInteractors()
        listView.delegate = self
    }

    func reload() {
        dataController.reload()
    }
}

extension AccountAssetListViewController {
    private func addUI() {
        addListBackground()
        addList()
    }

    private func updateUIWhenViewDidLayoutSubviews() {
        updateListBackgroundWhenViewDidLayoutSubviews()
        updateListWhenViewDidLayoutSubviews()
    }

    private func updateUIWhenListDidScroll() {
        updateListBackgroundWhenListDidScroll()
    }

    private func addListBackground() {
        listBackgroundView.customizeAppearance(
            [
                .backgroundColor(AppColors.Shared.Helpers.heroBackground)
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
                
                item.observe(event: .primaryAction) {
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
                item.observe(event: .secondaryAction) {
                    [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.eventHandler?(.addAsset)
                }
            case .watchAccountAssetManagement:
                let item = cell as! ManagementItemCell

                item.observe(event: .primaryAction) {
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

            item.observe(event: .buyAlgo) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.buyAlgo)
            }

            item.observe(event: .send) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.send)
            }

            item.observe(event: .address) {
                [weak self] in
                guard let self = self else {
                    return
                }

                self.eventHandler?(.address)
            }

            item.observe(event: .more) {
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
            case .algo:
                openAlgoDetail()
            case .asset:
                let assetIndex = indexPath.item
                
                if let assetDetail = dataController[assetIndex] {
                    self.openAssetDetail(assetDetail, on: self)
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
            backgroundColor: AppColors.Shared.System.background.uiColor
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
            backgroundColor: AppColors.Shared.System.background.uiColor
        )
    }
}

extension AccountAssetListViewController {
    private func openAlgoDetail() {
        open(
            .algosDetail(
                draft: AlgoTransactionListing(
                    accountHandle: accountHandle
                )
            ),
            by: .push
        )
    }

    private func openAssetDetail(
        _ asset: StandardAsset,
        on screen: UIViewController
    ) {
        screen.open(
            .assetDetail(
                draft: AssetTransactionListing(
                    accountHandle: accountHandle,
                    asset: asset
                )
            ),
            by: .push
        )
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
    func addAsset(_ assetDetail: StandardAsset) {
        dataController.addedAssetDetails.append(assetDetail)
    }

    func removeAsset(_ assetDetail: StandardAsset) {
        dataController.removedAssetDetails.append(assetDetail)
    }
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
        case manageAssets(isWatchAccount: Bool)
        case addAsset
        case buyAlgo
        case send
        case address
        case more
    }
}
