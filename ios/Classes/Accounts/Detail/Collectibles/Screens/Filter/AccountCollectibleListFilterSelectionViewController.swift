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

//   AccountCollectibleListFilterSelectionViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class AccountCollectibleListFilterSelectionViewController: ScrollScreen {
    var uiInteractions = UIInteractions()

    private lazy var contextView = VStackView()
    private lazy var displayOptedInCollectibleAssetsInCollectibleListFilterItemView = AssetFilterItemView()

    private lazy var filterOptions = CollectibleFilterOptions()

    private let theme: AccountCollectibleListFilterSelectionViewControllerTheme

    init(
        theme: AccountCollectibleListFilterSelectionViewControllerTheme = .init(),
        api: ALGAPI?
    ) {
        self.theme = theme
        
        super.init(api: api)
    }

    override func configureNavigationBar() {
        super.configureNavigationBar()

        addBarButtons()

        navigationItem.largeTitleDisplayMode =  .never
        navigationItem.title = "collectible-filter-selection-title".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addUI()
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [unowned self] in
            self.performChanges()
        }

        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension AccountCollectibleListFilterSelectionViewController {
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
        addDisplayOptedInCollectibleAssetsInCollectibleListFilterItem()
    }

    private func addDisplayOptedInCollectibleAssetsInCollectibleListFilterItem() {
        displayOptedInCollectibleAssetsInCollectibleListFilterItemView.customize(theme.filterItem)
        displayOptedInCollectibleAssetsInCollectibleListFilterItemView.bindData(DisplayOptedInCollectibleAssetsInCollectibleListFilterItemViewModel())

        displayOptedInCollectibleAssetsInCollectibleListFilterItemView.isOn = filterOptions.displayOptedInCollectibleAssetsInCollectibleList

        contextView.addArrangedSubview(displayOptedInCollectibleAssetsInCollectibleListFilterItemView)
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    private func performChanges() {
        if !hasChanges() {
            uiInteractions.didCancel?()
            return
        }

        saveFilters()
        uiInteractions.didComplete?()
    }

    private func saveFilters() {
        filterOptions.displayOptedInCollectibleAssetsInCollectibleList = displayOptedInCollectibleAssetsInCollectibleListFilterItemView.isOn
    }

    private func hasChanges() -> Bool {
        let hasChanges = filterOptions.displayOptedInCollectibleAssetsInCollectibleList != displayOptedInCollectibleAssetsInCollectibleListFilterItemView.isOn
        return hasChanges
    }
}

extension AccountCollectibleListFilterSelectionViewController {
    struct UIInteractions {
        var didComplete: (() -> Void)?
        var didCancel: (() -> Void)?
    }
}
