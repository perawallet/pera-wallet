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
//  SettingsView.swift

import UIKit

class SettingsView: BaseView {
    
    private lazy var settingsHeaderView: MainHeaderView = {
        let view = MainHeaderView()
        view.setTitle("settings-title".localized)
        view.setQRButtonHidden(true)
        view.setAddButtonHidden(true)
        view.setTestNetLabelHidden(true)
        return view
    }()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 8.0, right: 0.0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = Colors.Settings.background
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        
        collectionView.register(SettingsDetailCell.self, forCellWithReuseIdentifier: SettingsDetailCell.reusableIdentifier)
        collectionView.register(SettingsInfoCell.self, forCellWithReuseIdentifier: SettingsInfoCell.reusableIdentifier)
        collectionView.register(SettingsToggleCell.self, forCellWithReuseIdentifier: SettingsToggleCell.reusableIdentifier)
        collectionView.register(
            SettingsFooterSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: SettingsFooterSupplementaryView.reusableIdentifier
        )
        return collectionView
    }()
    
    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func prepareLayout() {
        setupSettingsHeaderViewLayout()
        setupCollectionViewLayout()
    }
}

extension SettingsView {
    private func setupSettingsHeaderViewLayout() {
        addSubview(settingsHeaderView)
        
        settingsHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(settingsHeaderView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension Colors {
    fileprivate enum Settings {
        static let background = color("settingsBackgroundColor")
    }
}
