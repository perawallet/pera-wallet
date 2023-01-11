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

//   ManagementOptionsViewController.swift

import Foundation
import MacaroonBottomSheet
import MacaroonUIKit
import SwiftUI

final class ManagementOptionsViewController:
    BaseScrollViewController,
    BottomSheetScrollPresentable {
    weak var delegate: ManagementOptionsViewControllerDelegate?

    private lazy var theme = Theme()
    private lazy var contextView = VStackView()

    private let managementType: ManagementType

    init(
        managementType: ManagementType,
        configuration: ViewControllerConfiguration
    ) {
        self.managementType = managementType

        super.init(configuration: configuration)
    }

    override func configureAppearance() {
        switch managementType {
        case .assets,
             .watchAccountAssets:
            title = "options-manage-assets".localized
        case .collectibles:
            title = "options-manage-collectibles".localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        build()
    }

    private func build() {
        addBackground()
        addContext()
        addButtons()
    }
}

extension ManagementOptionsViewController {
    private func addBackground() {
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    private func addContext() {
        contentView.addSubview(contextView)

        contextView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: theme.contentPaddings.top,
            leading: theme.contentPaddings.leading,
            bottom: theme.contentPaddings.bottom,
            trailing: theme.contentPaddings.trailing
        )

        contextView.isLayoutMarginsRelativeArrangement = true

        contextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addButtons() {
        switch managementType {
        case .assets:
            addSortButton()
            addFilterAssetsButton()
            addRemoveButton()
        case .collectibles:
            addSortButton()
            addFilterCollectiblesButton()
        case .watchAccountAssets:
            addSortButton()
            addFilterAssetsButton()
        }
    }
    
    private func addSortButton() {
        addButton(
            SortListItemButtonViewModel(),
            #selector(sort)
        )
    }
    
    private func addRemoveButton() {
        addButton(
            RemoveAssetsListItemButtonViewModel(),
            #selector(removeAssets)
        )
    }

    private func addFilterCollectiblesButton() {
        addButton(
            FilterCollectiblesItemButtonViewModel(),
            #selector(filterCollectibles)
        )
    }
    
    private func addFilterAssetsButton() {
        addButton(
            FilterAssetsListItemButtonViewModel(),
            #selector(filterAssets)
        )
    }
    
    private func addButton(
        _ viewModel: ListItemButtonViewModel,
        _ selector: Selector
    ) {
        let button = ListItemButton()
        
        button.customize(theme.listItemButtonTheme)
        button.bindData(viewModel)
        
        contextView.addArrangedSubview(button)
        
        button.addTouch(
            target: self,
            action: selector
        )
    }
}

extension ManagementOptionsViewController {
    @objc
    private func sort() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.managementOptionsViewControllerDidTapSort(self)
        }
    }
    @objc
    private func removeAssets() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.managementOptionsViewControllerDidTapRemove(self)
        }
    }

    @objc
    private func filterCollectibles() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }

            self.delegate?.managementOptionsViewControllerDidTapFilterCollectibles(self)
        }
    }
    
    @objc
    private func filterAssets() {
        closeScreen(by: .dismiss) {
            [weak self] in
            guard let self = self else { return }
            
            self.delegate?.managementOptionsViewControllerDidTapFilterAssets(self)
        }
    }
}

extension ManagementOptionsViewController {
    enum ManagementType {
        case watchAccountAssets
        case assets
        case collectibles
    }
}

protocol ManagementOptionsViewControllerDelegate: AnyObject {
    func managementOptionsViewControllerDidTapSort(
        _ managementOptionsViewController: ManagementOptionsViewController
    )
    func managementOptionsViewControllerDidTapRemove(
        _ managementOptionsViewController: ManagementOptionsViewController
    )
    func managementOptionsViewControllerDidTapFilterCollectibles(
        _ managementOptionsViewController: ManagementOptionsViewController
    )
    func managementOptionsViewControllerDidTapFilterAssets(
        _ managementOptionsViewController: ManagementOptionsViewController
    )
}
