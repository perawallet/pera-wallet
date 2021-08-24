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
//  RekeyConfirmationDataSource.swift

import UIKit

class RekeyConfirmationDataSource: NSObject {
    
    weak var delegate: RekeyConfirmationDataSourceDelegate?
    
    private let layoutBuilder = AssetListLayoutBuilder()
    private let rekeyConfirmationViewModel: RekeyConfirmationViewModel
    private let account: Account
    
    private(set) var allAssetsDisplayed = false
    
    init(account: Account, rekeyConfirmationViewModel: RekeyConfirmationViewModel) {
        self.account = account
        self.rekeyConfirmationViewModel = rekeyConfirmationViewModel
        allAssetsDisplayed = account.assetDetails.count < 2
        super.init()
    }
}

extension RekeyConfirmationDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if account.assetDetails.isEmpty {
            return 1
        }
        
        if allAssetsDisplayed {
            return account.assetDetails.count + 1
        } else {
            return 2
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
        }
        return dequeueAssetCells(in: collectionView, cellForItemAt: indexPath)
    }
        
    private func dequeueAlgoAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlgoAssetCell.reusableIdentifier,
            for: indexPath) as? AlgoAssetCell {
            cell.bind(AlgoAssetViewModel(account: account))
            return cell
        }
        fatalError("Index path is out of bounds")
    }
        
    private func dequeueAssetCells(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let assetDetail = account.assetDetails[safe: indexPath.item - 1],
            let assets = account.assets,
            let asset = assets.first(where: { $0.id == assetDetail.id }) {
            let cell = layoutBuilder.dequeueAssetCells(in: collectionView, cellForItemAt: indexPath, for: assetDetail)
            cell.bind(AssetViewModel(assetDetail: assetDetail, asset: asset))
            return cell
        }
            
        fatalError("Index path is out of bounds")
    }
        
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountHeaderSupplementaryView {
                headerView.bind(AccountHeaderSupplementaryViewModel(account: account, isActionEnabled: false))
                return headerView
            }
        } else {
            if let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: RekeyConfirmationFooterSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? RekeyConfirmationFooterSupplementaryView {
                footerView.delegate = self
                rekeyConfirmationViewModel.configure(footerView)
                return footerView
            }
        }
        
        fatalError("Unexpected element kind")
    }
}

extension RekeyConfirmationDataSource: RekeyConfirmationFooterSupplementaryViewDelegate {
    func rekeyConfirmationFooterSupplementaryViewDidShowMoreAssets(
        _ rekeyConfirmationFooterSupplementaryView: RekeyConfirmationFooterSupplementaryView
    ) {
        allAssetsDisplayed = !allAssetsDisplayed
        delegate?.rekeyConfirmationDataSourceDidShowMoreAssets(self)
    }
}

protocol RekeyConfirmationDataSourceDelegate: AnyObject {
    func rekeyConfirmationDataSourceDidShowMoreAssets(_ rekeyConfirmationDataSource: RekeyConfirmationDataSource)
}
