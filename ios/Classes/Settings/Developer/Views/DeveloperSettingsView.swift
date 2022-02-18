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
//  DeveloperSettingsView.swift

import UIKit
import MacaroonUIKit

final class DeveloperSettingsView: View {
    private lazy var theme = DeveloperSettingsViewTheme()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = theme.cellSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = .zero
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(SettingsDetailCell.self, forCellWithReuseIdentifier: SettingsDetailCell.reusableIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customize(theme)
    }
    
    func customize(_ theme: DeveloperSettingsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        addCollectionView()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
    
    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension DeveloperSettingsView {
    private func addCollectionView() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
