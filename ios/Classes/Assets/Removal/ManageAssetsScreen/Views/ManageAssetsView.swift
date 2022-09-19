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
//  ManageAssetsView.swift

import UIKit
import MacaroonUIKit

final class ManageAssetsView: View {
    private lazy var theme = ManageAssetsViewTheme()
    private lazy var titleLabel = Label()
    private lazy var subtitleLabel = Label()
    private lazy var searchInputView = SearchInputView()

    private(set) lazy var assetsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        return collectionView
    }()
    
    func customize(_ theme: ManageAssetsViewTheme) {
        customizeBaseAppearance(backgroundColor: theme.backgroundColor)

        addTitleLabel(theme)
        addSubitleLabel(theme)
        addSearchInputView(theme)
        addAssetsCollectionView(theme)
    }

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}
}

extension ManageAssetsView {
    private func addTitleLabel(_ theme: ManageAssetsViewTheme) {
        titleLabel.customizeAppearance(theme.title)
        titleLabel.editText = theme.titleText

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalToSuperview().inset(theme.titleTopPadding)
        }
    }

    private func addSubitleLabel(_ theme: ManageAssetsViewTheme) {
        subtitleLabel.customizeAppearance(theme.subtitle)
        subtitleLabel.editText = theme.subtitleText
        
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
            $0.top.equalTo(titleLabel.snp.bottom).offset(theme.subtitleTopPadding)
        }
    }
    
    private func addSearchInputView(_ theme: ManageAssetsViewTheme) {
        searchInputView.customize(theme.searchInputViewTheme)
        
        addSubview(searchInputView)
        searchInputView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(theme.searchInputViewTopPadding)
            $0.leading.trailing.equalToSuperview().inset(theme.horizontalPadding)
        }
    }

    private func addAssetsCollectionView(_ theme: ManageAssetsViewTheme) {
        addSubview(assetsCollectionView)
        assetsCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchInputView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ManageAssetsView {
    func setSearchInputDelegate(_ delegate: SearchInputViewDelegate?) {
        searchInputView.delegate = delegate
    }

}
