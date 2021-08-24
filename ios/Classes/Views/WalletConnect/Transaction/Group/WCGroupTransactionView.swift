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
//   WCGroupTransactionView.swift

import UIKit

class WCGroupTransactionView: BaseView {

    private let layout = Layout<LayoutConstants>()

    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(
            WCGroupTransactionItemCell.self,
            forCellWithReuseIdentifier: WCGroupTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCAppCallTransactionItemCell.self,
            forCellWithReuseIdentifier: WCAppCallTransactionItemCell.reusableIdentifier
        )
        collectionView.register(
            WCGroupAnotherAccountTransactionItemCell.self,
            forCellWithReuseIdentifier: WCGroupAnotherAccountTransactionItemCell.reusableIdentifier
        )

        collectionView.register(
            WCGroupTransactionSupplementaryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: WCGroupTransactionSupplementaryHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    override func prepareLayout() {
        super.prepareLayout()
        setupTransactionViewLayout()
    }
}

extension WCGroupTransactionView {
    private func setupTransactionViewLayout() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(safeAreaBottom + layout.current.verticalInset)
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

extension WCGroupTransactionView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let verticalInset: CGFloat = 20.0
    }
}
