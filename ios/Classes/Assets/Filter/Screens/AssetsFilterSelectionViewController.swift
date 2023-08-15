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

//   AssetsFilterSelectionViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AssetsFilterSelectionViewController: ScrollScreen {
    var uiInteractions = UIInteractions()

    private lazy var contextView = VStackView()
    private lazy var hideAssetsWithNoBalanceInAssetListFilterItemView = AssetFilterItemView()
    private lazy var displayCollectibleAssetsInAssetListFilterItemView = AssetFilterItemView()
    private lazy var displayOptedInCollectibleAssetsFilterInAssetListItemView = AssetFilterItemView()

    private lazy var filterOptions = AssetFilterOptions()

    private let theme: AssetsFilterSelectionViewControllerTheme

    init(
        theme: AssetsFilterSelectionViewControllerTheme = .init(),
        api: ALGAPI?
    ) {
        self.theme = theme
        
        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        addBarButtons()
        bindNavigationItemTitle()

        navigationItem.largeTitleDisplayMode =  .never
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }
}

extension AssetsFilterSelectionViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [unowned self] in
            self.performChanges()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }

    private func bindNavigationItemTitle() {
        title = "asset-filter-title".localized
    }
}

extension AssetsFilterSelectionViewController {
    private func addUI() {
        addBackground()
        addContext()
    }

    private func addBackground() {
        view.customizeAppearance(theme.background)
    }

    private func addContext() {
        contentView.addSubview(contextView)
        contextView.spacing = theme.spacingBetweenFilterItems
        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )
        contextView.isLayoutMarginsRelativeArrangement = true
        contextView.snp.makeConstraints {
            $0.top == 0
            $0.leading == 0
            $0.bottom == 0
            $0.trailing == 0
        }

        addFilterItems()
    }

    private func addFilterItems() {
        addHideAssetsWithNoBalanceInAssetListFilterItemView()
        addDisplayCollectibleAssetsInAssetListFilterItemView()
        addDisplayOptedInCollectibleAssetsFilterInAssetListItemView()
    }

    private func addHideAssetsWithNoBalanceInAssetListFilterItemView() {
        hideAssetsWithNoBalanceInAssetListFilterItemView.customize(theme.filterItem)
        hideAssetsWithNoBalanceInAssetListFilterItemView.bindData(HideAssetsWithNoBalanceInAssetListFilterItemViewModel())

        hideAssetsWithNoBalanceInAssetListFilterItemView.isOn = filterOptions.hideAssetsWithNoBalanceInAssetList

        contextView.addArrangedSubview(hideAssetsWithNoBalanceInAssetListFilterItemView)
    }

    private func addDisplayCollectibleAssetsInAssetListFilterItemView() {
        displayCollectibleAssetsInAssetListFilterItemView.customize(theme.filterItem)
        displayCollectibleAssetsInAssetListFilterItemView.bindData(DisplayCollectibleAssetsInAssetListFilterItemViewModel())

        displayCollectibleAssetsInAssetListFilterItemView.isOn = filterOptions.displayCollectibleAssetsInAssetList

        contextView.addArrangedSubview(displayCollectibleAssetsInAssetListFilterItemView)

        displayCollectibleAssetsInAssetListFilterItemView.startObserving(event: .valueChanged) {
            [unowned self, displayCollectibleAssetsInAssetListFilterItemView] in

            if !displayCollectibleAssetsInAssetListFilterItemView.isOn {
                displayOptedInCollectibleAssetsFilterInAssetListItemView.isOn = false
            }

            displayOptedInCollectibleAssetsFilterInAssetListItemView.isEnabled = displayCollectibleAssetsInAssetListFilterItemView.isOn
        }
    }

    private func addDisplayOptedInCollectibleAssetsFilterInAssetListItemView() {
        displayOptedInCollectibleAssetsFilterInAssetListItemView.customize(theme.filterItem)
        displayOptedInCollectibleAssetsFilterInAssetListItemView.bindData(DisplayOptedInCollectibleAssetsFilterInAssetListItemViewModel())

        displayOptedInCollectibleAssetsFilterInAssetListItemView.isOn = filterOptions.displayOptedInCollectibleAssetsInAssetList
        displayOptedInCollectibleAssetsFilterInAssetListItemView.isEnabled = displayCollectibleAssetsInAssetListFilterItemView.isOn

        contextView.addArrangedSubview(displayOptedInCollectibleAssetsFilterInAssetListItemView)
    }
}

extension AssetsFilterSelectionViewController {
    private func performChanges() {
        if !hasChanges() {
            uiInteractions.didCancel?()
            return
        }

        saveFilters()
        uiInteractions.didComplete?()
    }

    private func saveFilters() {
        filterOptions.hideAssetsWithNoBalanceInAssetList = hideAssetsWithNoBalanceInAssetListFilterItemView.isOn
        filterOptions.displayCollectibleAssetsInAssetList = displayCollectibleAssetsInAssetListFilterItemView.isOn
        filterOptions.displayOptedInCollectibleAssetsInAssetList = displayOptedInCollectibleAssetsFilterInAssetListItemView.isOn
    }

    private func hasChanges() -> Bool {
        if filterOptions.hideAssetsWithNoBalanceInAssetList != hideAssetsWithNoBalanceInAssetListFilterItemView.isOn {
            return true
        }

        if filterOptions.displayCollectibleAssetsInAssetList != displayCollectibleAssetsInAssetListFilterItemView.isOn {
            return true
        }

        if filterOptions.displayOptedInCollectibleAssetsInAssetList != displayOptedInCollectibleAssetsFilterInAssetListItemView.isOn {
            return true
        }

        return false
    }
}

extension AssetsFilterSelectionViewController {
    struct UIInteractions {
        var didComplete: (() -> Void)?
        var didCancel: (() -> Void)?
    }
}
