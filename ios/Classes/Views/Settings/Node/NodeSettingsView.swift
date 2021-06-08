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
//  NodeSettingsView.swift

import UIKit

class NodeSettingsView: BaseView {
    
    private let layout = Layout<LayoutConstants>()
    
    private lazy var headerView = NodeSettingsHeaderView()
    
    private(set) lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 12.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Colors.Background.primary
        collectionView.contentInset = .zero
        collectionView.register(NodeSelectionCell.self, forCellWithReuseIdentifier: NodeSelectionCell.reusableIdentifier)
        return collectionView
    }()
    
    override func prepareLayout() {
        setupHeaderViewLayout()
        setupCollectionViewLayout()
    }
}

extension NodeSettingsView {
    private func setupHeaderViewLayout() {
        addSubview(headerView)
        
        headerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(layout.current.headerHeight)
        }
    }
    
    private func setupCollectionViewLayout() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension NodeSettingsView {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let headerHeight: CGFloat = 210.0
    }
}
