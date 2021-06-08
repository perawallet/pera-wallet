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
//  AssetsCollectionView.swift

import UIKit

class AssetsCollectionView: UICollectionView {
    
    init(containsPendingAssets: Bool) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.0
        super.init(frame: .zero, collectionViewLayout: flowLayout)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerAssetCells()
        
        if containsPendingAssets {
            registerPendingAssetCells()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerAssetCells() {
        register(AssetCell.self, forCellWithReuseIdentifier: AssetCell.reusableIdentifier)
        register(OnlyNameAssetCell.self, forCellWithReuseIdentifier: OnlyNameAssetCell.reusableIdentifier)
        register(OnlyUnitNameAssetCell.self, forCellWithReuseIdentifier: OnlyUnitNameAssetCell.reusableIdentifier)
        register(UnnamedAssetCell.self, forCellWithReuseIdentifier: UnnamedAssetCell.reusableIdentifier)
        register(UnverifiedAssetCell.self, forCellWithReuseIdentifier: UnverifiedAssetCell.reusableIdentifier)
        register(
            UnverifiedOnlyNameAssetCell.self,
            forCellWithReuseIdentifier: UnverifiedOnlyNameAssetCell.reusableIdentifier
        )
        register(
            UnverifiedOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: UnverifiedOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(UnverifiedUnnamedAssetCell.self, forCellWithReuseIdentifier: UnverifiedUnnamedAssetCell.reusableIdentifier)
    }
    
    private func registerPendingAssetCells() {
        register(PendingAssetCell.self, forCellWithReuseIdentifier: PendingAssetCell.reusableIdentifier)
        register(PendingOnlyNameAssetCell.self, forCellWithReuseIdentifier: PendingOnlyNameAssetCell.reusableIdentifier)
        register(
            PendingOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: PendingOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(PendingUnnamedAssetCell.self, forCellWithReuseIdentifier: PendingUnnamedAssetCell.reusableIdentifier)
        register(PendingUnverifiedAssetCell.self, forCellWithReuseIdentifier: PendingUnverifiedAssetCell.reusableIdentifier)
        register(
            PendingUnverifiedOnlyNameAssetCell.self,
            forCellWithReuseIdentifier: PendingUnverifiedOnlyNameAssetCell.reusableIdentifier
        )
        register(
            PendingUnverifiedOnlyUnitNameAssetCell.self,
            forCellWithReuseIdentifier: PendingUnverifiedOnlyUnitNameAssetCell.reusableIdentifier
        )
        register(
            PendingUnverifiedUnnamedAssetCell.self,
            forCellWithReuseIdentifier: PendingUnverifiedUnnamedAssetCell.reusableIdentifier
        )
    }
}
