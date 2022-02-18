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
//  OptionsView.swift

import UIKit
import MacaroonUIKit

final class OptionsView: View {
    private lazy var theme = OptionsViewTheme()
    
    private(set) lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.register(OptionsCell.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: OptionsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addOptionsCollectionView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension OptionsView {
    private func addOptionsCollectionView(_ theme: OptionsViewTheme) {
        addSubview(optionsCollectionView)
        optionsCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(theme.topInset)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}
