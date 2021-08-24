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
//   WCSessionListView.swift

import UIKit

class WCSessionListView: BaseView {

    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 8.0
        flowLayout.minimumInteritemSpacing = 0.0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.backgroundColor = Colors.Background.tertiary
        collectionView.register(WCSessionItemCell.self, forCellWithReuseIdentifier: WCSessionItemCell.reusableIdentifier)
        return collectionView
    }()

    private lazy var contentStateView = ContentStateView()

    override func configureAppearance() {
        backgroundColor = Colors.Background.tertiary
    }

    override func prepareLayout() {
        prepareWholeScreenLayoutFor(collectionView)
        collectionView.backgroundView = contentStateView
    }
}

extension WCSessionListView {
    func setDelegate(_ delegate: UICollectionViewDelegate?) {
        collectionView.delegate = delegate
    }

    func setDataSource(_ dataSource: UICollectionViewDataSource?) {
        collectionView.dataSource = dataSource
    }
}
