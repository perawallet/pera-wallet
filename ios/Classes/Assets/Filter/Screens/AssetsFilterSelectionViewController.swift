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

final class AssetsFilterSelectionViewController: BaseScrollViewController {
    typealias EventHandler = (Event) -> Void
    
    var eventHandler: EventHandler?
    
    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var toggleTitleView = Label()
    private lazy var toggleDescriptionView = Label()
    private lazy var toggleView = Toggle()
    
    private let theme: AssetsFilterSelectionViewControllerTheme
    private var filterOptions = AssetFilterOptions()
    
    init(
        theme: AssetsFilterSelectionViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.theme = theme
        
        super.init(configuration: configuration)
    }
    
    override func configureNavigationBarAppearance() {
        bindNavigationItemTitle()
        addBarButtons()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        addContent()
    }
}

extension AssetsFilterSelectionViewController {
    private func bindNavigationItemTitle() {
        title = "asset-filter-title".localized
    }
    
    private func addBarButtons() {
        let doneBarButtonItem = ALGBarButtonItem(kind: .done(Colors.Link.primary.uiColor)) {
            [weak self] in
            guard let self = self else { return }
            self.performChanges()
        }
        
        rightBarButtonItems = [doneBarButtonItem]
    }
}

extension AssetsFilterSelectionViewController {
    private func performChanges() {
        if !hasChanges() {
            eventHandler?(.didCancel)
            return
        }

        saveOptions()
        eventHandler?(.didComplete)
    }

    private func saveOptions() {
        filterOptions.hideAssetsWithNoBalanceInAssetList = toggleView.isOn
    }

    private func hasChanges() -> Bool {
        return filterOptions.hideAssetsWithNoBalanceInAssetList != toggleView.isOn
    }
}

extension AssetsFilterSelectionViewController {
    private func addContent() {
        contentView.addSubview(contextView)
        contextView.snp.makeConstraints {
            $0.setPaddings(theme.contentEdgeInsets)
        }
        
        addToggleTitle()
        addToggle()
        addToggleDescription()
    }
    
    private func addToggleTitle() {
        toggleTitleView.customizeAppearance(theme.title)
        
        contextView.addSubview(toggleTitleView)
        toggleTitleView.snp.makeConstraints {
            $0.width <= contextView * theme.titleMaxWidthRatio
            $0.leading == 0
            $0.top == 0
            $0.greaterThanHeight(theme.titleMinHeight)
        }
    }
    
    private func addToggle() {
        contextView.addSubview(toggleView)
        toggleView.fitToHorizontalIntrinsicSize()
        toggleView.snp.makeConstraints {
            $0.leading >= toggleTitleView.snp.trailing + theme.minimumHorizontalSpacing
            $0.trailing == 0
            $0.centerY == toggleTitleView
        }
        
        toggleView.isOn = filterOptions.hideAssetsWithNoBalanceInAssetList
    }
    
    private func addToggleDescription() {
        toggleDescriptionView.customizeAppearance(theme.description)
        
        contextView.addSubview(toggleDescriptionView)
        toggleDescriptionView.snp.makeConstraints {
            $0.leading == 0
            $0.top == toggleTitleView.snp.bottom + theme.descriptionTopMargin
            $0.width == toggleTitleView
            $0.bottom == 0
        }
    }
}

extension AssetsFilterSelectionViewController {
    enum Event {
        case didComplete
        case didCancel
    }
}
