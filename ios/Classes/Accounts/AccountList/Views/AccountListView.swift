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
//  AccountListView.swift

import UIKit
import MacaroonUIKit

final class AccountListView: View {
    private lazy var theme = AccountListViewTheme()

    private(set) lazy var accountsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(theme.contentInset)
        collectionView.backgroundColor = theme.backgroundColor.uiColor
        return collectionView
    }()

    private lazy var searchNoContentView = NoContentView()

    func customize(_ theme: AccountListViewTheme) {
        searchNoContentView.customize(NoContentViewCommonTheme())
        searchNoContentView.bindData(AssetListSearchNoContentViewModel(hasBody: true))

        addAccountCollectionView(theme)
    }

    func customizeAppearance(_ styleSheet: AccountListViewTheme) {}

    func prepareLayout(_ layoutSheet: AccountListViewTheme) {}
}

extension AccountListView {
    private func addAccountCollectionView(_ theme: AccountListViewTheme) {
        addSubview(accountsCollectionView)
        accountsCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        accountsCollectionView.backgroundView = ContentStateView()
    }
}

extension AccountListView {
    func updateContentStateView(isEmpty: Bool) {
        accountsCollectionView.contentState = isEmpty ? .empty(searchNoContentView) : .none
    }
}
