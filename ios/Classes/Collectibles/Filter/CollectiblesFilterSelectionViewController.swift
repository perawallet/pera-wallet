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

//   CollectiblesFilterSelectionViewController.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectiblesFilterSelectionViewController: BaseScrollViewController {
    lazy var handlers = Handlers()

    private lazy var contextView = MacaroonUIKit.BaseView()
    private lazy var toggleTitleView = Label()
    private lazy var toggleDescriptionView = Label()
    private lazy var toggleView = Toggle()

    private let theme: CollectiblesFilterSelectionViewControllerTheme
    private let filter: Filter

    init(
        filter: Filter,
        theme: CollectiblesFilterSelectionViewControllerTheme = .init(),
        configuration: ViewControllerConfiguration
    ) {
        self.filter = filter
        self.theme = theme

        super.init(configuration: configuration)
    }

    override func configureNavigationBarAppearance() {
        bindNavigationItemTitle()
    }

    override func prepareLayout() {
        super.prepareLayout()

        addContent()
    }

    override func setListeners() {
        toggleView.addTarget(self, action: #selector(didChangeToggle(_:)), for: .touchUpInside)
    }

    @objc
    private func didChangeToggle(_ toggle: Toggle) {
        let filter: Filter = toggleView.isOn ? .all : .owned
        handlers.didChangeFilter?(filter)
    }
}

extension CollectiblesFilterSelectionViewController {
    private func bindNavigationItemTitle() {
        title = "collectible-filter-selection-title".localized
    }
}

extension CollectiblesFilterSelectionViewController {
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
            $0.top == theme.titleTopPadding
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

        toggleView.isOn = filter == .all
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

extension CollectiblesFilterSelectionViewController {
    struct Handlers {
        var didChangeFilter: ((Filter) -> Void)?
    }
}

extension CollectiblesFilterSelectionViewController {
    enum Filter: Int {
        case all = 1
        case owned
    }
}
