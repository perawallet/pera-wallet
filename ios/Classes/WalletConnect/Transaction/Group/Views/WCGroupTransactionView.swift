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
//   WCGroupTransactionView.swift

import UIKit
import MacaroonUIKit

final class WCGroupTransactionView: View {
    private lazy var theme = WCGroupTransactionViewTheme()

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = theme.cellSpacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(theme.collectionViewEdgeInsets)
        collectionView.register(WCGroupTransactionItemCell.self)
        collectionView.register(WCAppCallTransactionItemCell.self)
        collectionView.register(WCGroupAnotherAccountTransactionItemCell.self)
        collectionView.register(WCAssetConfigTransactionItemCell.self)
        collectionView.register(WCAssetConfigAnotherAccountTransactionItemCell.self)
        collectionView.register(header: WCGroupTransactionSupplementaryHeaderView.self)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        customize(theme)
    }

    func customize(_ theme: WCGroupTransactionViewTheme) {
        addTransactionView()
    }

    func customizeAppearance(_ styleSheet: NoStyleSheet) {}

    func prepareLayout(_ layoutSheet: NoLayoutSheet) {}
}

extension WCGroupTransactionView {
    private func addTransactionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension WCGroupTransactionView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }

    func reloadData() {
        collectionView.reloadData()
    }
}
