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
//  AppearanceSelectionViewController.swift

import UIKit

final class AppearanceSelectionViewController: BaseViewController {
    private lazy var theme = Theme()
    private lazy var appearanceSelectionView = SingleSelectionListView()
    
    override func configureAppearance() {
        super.configureAppearance()
        
        title = "settings-theme-set".localized
        view.customizeBaseAppearance(backgroundColor: theme.backgroundColor)
    }
    
    override func linkInteractors() {
        super.linkInteractors()
        
        appearanceSelectionView.linkInteractors()
        appearanceSelectionView.setDataSource(self)
        appearanceSelectionView.setListDelegate(self)
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        prepareWholeScreenLayoutFor(appearanceSelectionView)
    }
}

extension AppearanceSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserInterfaceStyle.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
            for: indexPath) as? SingleSelectionCell else {
                fatalError("Index path is out of bounds")
            }
        
        if let appearance = UserInterfaceStyle.allCases[safe: indexPath.item] {
            let isSelected = session?.userInterfaceStyle == appearance
            cell.bindData(SingleSelectionViewModel(title: appearance.representation(), isSelected: isSelected))
            return cell
        }
    
        fatalError("Index path is out of bounds")
    }
}

extension AppearanceSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let appearance = UserInterfaceStyle.allCases[safe: indexPath.item] {
            api?.session.userInterfaceStyle = appearance
            UserInterfaceStyleController.setNeedsUserInterfaceStyleUpdate(appearance)
            appearanceSelectionView.reloadData()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: theme.cellWidth, height: theme.cellHeight)
    }
}

enum UserInterfaceStyle: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    func representation() -> String {
        switch self {
        case .system:
            return "settings-theme-system".localized
        case .light:
            return "settings-theme-light".localized
        case .dark:
            return "settings-theme-dark".localized
        }
    }
}
