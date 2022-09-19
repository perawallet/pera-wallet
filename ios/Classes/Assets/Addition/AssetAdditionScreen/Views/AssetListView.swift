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
//   AssetListView.swift

import UIKit
import MacaroonUIKit

final class AssetListView: View {
    private lazy var theme = AssetListViewTheme()

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        collectionView.keyboardDismissMode = .onDrag
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private lazy var searchNoContentView = NoContentView()

    func customize(_ theme: AssetListViewTheme) {
        searchNoContentView.customize(NoContentViewCommonTheme())
        searchNoContentView.bindData(AssetListSearchNoContentViewModel(hasBody: true))

        addCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: AssetListViewTheme) {}

    func prepareLayout(_ layoutSheet: AssetListViewTheme) {}
}

extension AssetListView {
    private func addCollectionView(_ theme: AssetListViewTheme) {
        collectionView.backgroundView = ContentStateView()

        addSubview(collectionView)
        collectionView.pinToSuperview()
    }

    func updateContentStateView(_ isEmpty: Bool) {
        collectionView.contentState = isEmpty ? .empty(searchNoContentView) : .none
    }
}
