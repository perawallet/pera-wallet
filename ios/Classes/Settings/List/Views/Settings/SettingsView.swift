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
//  SettingsView.swift

import UIKit
import MacaroonUIKit

final class SettingsView: View {
    private lazy var theme = SettingsViewTheme()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        flowLayout.sectionInset = UIEdgeInsets(theme.sectionInset)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.register(SettingsDetailCell.self)
        collectionView.register(SettingsLoadingCell.self)
        collectionView.register(SettingsToggleCell.self)
        collectionView.register(footer: SettingsFooterSupplementaryView.self)
        collectionView.register(header: SingleGrayTitleHeaderSuplementaryView.self)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }
    
    func customize(_ theme: SettingsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)
        
        addCollectionView()
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
    
    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension SettingsView {
    private func addCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
