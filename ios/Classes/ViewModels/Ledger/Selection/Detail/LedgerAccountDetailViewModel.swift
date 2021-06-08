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
//  LedgerAccountDetailViewModel.swift

import UIKit

class LedgerAccountDetailViewModel {
    
    private(set) var subtitle: String?
    private(set) var assetViews: [UIView] = []
    private(set) var rekeyedAccountViews: [UIView]?
    
    init(account: Account, rekeyedAccounts: [Account]?) {
        setAssetViews(from: account)
        setSubtitle(from: account)
        setRekeyedAccountViews(from: account, and: rekeyedAccounts)
    }
    
    private func setAssetViews(from account: Account) {
        addLedgerInfoAccountNameView(for: account)
        addAlgoView(for: account)
        addAssetViews(for: account)
    }
    
    private func setSubtitle(from account: Account) {
        subtitle = account.isRekeyed() ? "ledger-account-detail-can-signed".localized : "ledger-account-detail-can-sign".localized
    }
    
    private func setRekeyedAccountViews(from account: Account, and rekeyedAccounts: [Account]?) {
        if account.isRekeyed() {
            let roundedAccountNameView = RoundedAccountNameView()
            roundedAccountNameView.bind(AuthAccountNameViewModel(account: account))
            rekeyedAccountViews = [roundedAccountNameView]
        } else {
            guard let rekeyedAccounts = rekeyedAccounts,
                  !rekeyedAccounts.isEmpty else {
                return
            }
            
            rekeyedAccountViews = []
            
            rekeyedAccounts.forEach { rekeyedAccount in
                let roundedAccountNameView = RoundedAccountNameView()
                roundedAccountNameView.bind(AccountNameViewModel(account: rekeyedAccount))
                rekeyedAccountViews?.append(roundedAccountNameView)
            }
        }
    }
}

extension LedgerAccountDetailViewModel {
    private func addLedgerInfoAccountNameView(for account: Account) {
        let ledgerInfoAccountNameView = LedgerInfoAccountNameView()
        ledgerInfoAccountNameView.bind(AccountNameViewModel(account: account))
        assetViews.append(ledgerInfoAccountNameView)
    }
    
    private func addAlgoView(for account: Account) {
        let algoView = AlgoAssetView()
        algoView.bind(AlgoAssetViewModel(account: account))
        assetViews.append(algoView)
        
        if account.assets.isNilOrEmpty {
            algoView.setSeparatorHidden(true)
        }
    }
    
    private func addAssetViews(for account: Account) {
        for (index, assetDetail) in account.assetDetails.enumerated() {
            guard let asset = account.assets?[safe: index] else {
                continue
            }
            
            if assetDetail.isVerified {
                addVerifiedAssetViews(assetDetail: assetDetail, asset: asset)
            } else {
                addUnverifiedAssetViews(assetDetail: assetDetail, asset: asset)
            }
        }
    }
    
    private func addVerifiedAssetViews(assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(AssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(OnlyNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(OnlyUnitNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnnamedAssetCell(), assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addUnverifiedAssetViews(assetDetail: AssetDetail, asset: Asset) {
        if assetDetail.hasBothDisplayName() {
            addAssetView(UnverifiedAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyAssetName() {
            addAssetView(UnverifiedOnlyNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasOnlyUnitName() {
            addAssetView(UnverifiedOnlyUnitNameAssetCell(), assetDetail: assetDetail, asset: asset)
        } else if assetDetail.hasNoDisplayName() {
            addAssetView(UnverifiedUnnamedAssetCell(), assetDetail: assetDetail, asset: asset)
        }
    }
    
    private func addAssetView(_ view: BaseAssetCell, assetDetail: AssetDetail, asset: Asset) {
        view.bind(AssetViewModel(assetDetail: assetDetail, asset: asset))
        assetViews.append(view)
    }
}
