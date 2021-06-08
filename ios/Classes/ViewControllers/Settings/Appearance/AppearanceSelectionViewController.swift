// Copyright 2019 Algorand, Inc.

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

class AppearanceSelectionViewController: BaseViewController {

    weak var delegate: AppearanceSelectionViewControllerDelegate?
    
    private lazy var appearanceSelectionView = SingleSelectionListView()
    
    override func configureAppearance() {
        view.backgroundColor = Colors.Background.tertiary
        title = "settings-theme-set".localized
    }
    
    override func linkInteractors() {
        appearanceSelectionView.setDataSource(self)
        appearanceSelectionView.setListDelegate(self)
    }
    
    override func prepareLayout() {
        setupAppearanceSelectionViewLayout()
    }
}

extension AppearanceSelectionViewController {
    private func setupAppearanceSelectionViewLayout() {
        view.addSubview(appearanceSelectionView)
        
        appearanceSelectionView.snp.makeConstraints { make in
            make.top.safeEqualToTop(of: self)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AppearanceSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return UserInterfaceStyle.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let appearance = UserInterfaceStyle.allCases[safe: indexPath.item],
           let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SingleSelectionCell.reusableIdentifier,
                for: indexPath
            ) as? SingleSelectionCell {
            
            let isSelected = session?.userInterfaceStyle == appearance
            cell.contextView.bind(SingleSelectionViewModel(title: appearance.representation(), isSelected: isSelected))
            return cell
        }
    
        fatalError("Index path is out of bounds")
    }
}

extension AppearanceSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let appearance = UserInterfaceStyle.allCases[safe: indexPath.item] {
            api?.session.userInterfaceStyle = appearance
            UIApplication.shared.rootViewController()?.changeUserInterfaceStyle(to: appearance)
            appearanceSelectionView.reloadData()
            delegate?.appearanceSelectionViewControllerDidUpdateUserInterfaceStyle(self)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 72.0)
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

protocol AppearanceSelectionViewControllerDelegate: class {
    func appearanceSelectionViewControllerDidUpdateUserInterfaceStyle(
        _ appearanceSelectionViewController: AppearanceSelectionViewController
    )
}
