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
//  AssetListLayoutBuilder.swift

import UIKit

struct AssetListLayoutBuilder {
    func dequeueAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.isVerified {
            return dequeueVerifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        } else {
            return dequeueUnverifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        }
    }
    
    func dequeuePendingAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.isVerified {
            return dequeuePendingVerifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        } else {
            return dequeuePendingUnverifiedAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
        }
    }
}
    
extension AssetListLayoutBuilder {
    private func dequeuePendingVerifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeuePendingUnverifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BasePendingAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PendingUnverifiedUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? PendingUnverifiedUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeueVerifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AssetCell.reusableIdentifier,
                for: indexPath
            ) as? AssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? OnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? OnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
    
    private func dequeueUnverifiedAssetCells(
        in collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath,
        for assetDetail: AssetDetail
    ) -> BaseAssetCell {
        if assetDetail.hasBothDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyAssetName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedOnlyNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedOnlyNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasOnlyUnitName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedOnlyUnitNameAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedOnlyUnitNameAssetCell {
                return cell
            }
        }
        
        if assetDetail.hasNoDisplayName() {
            if let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UnverifiedUnnamedAssetCell.reusableIdentifier,
                for: indexPath
            ) as? UnverifiedUnnamedAssetCell {
                return cell
            }
        }
        
        fatalError("Unexpected Element")
    }
}
