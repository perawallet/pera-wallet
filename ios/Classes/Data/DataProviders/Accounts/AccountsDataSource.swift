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
//  AccountsDataSource.swift

import UIKit
import SwiftDate

class AccountsDataSource: NSObject, UICollectionViewDataSource {
    
    weak var delegate: AccountsDataSourceDelegate?
    
    private let layout = Layout<LayoutConstants>()
    
    private let layoutBuilder = AssetListLayoutBuilder()
    
    var accounts: [Account] = UIApplication.shared.appConfiguration?.session.accounts ?? []
    
    private var addedAssetDetails: [Account: Set<AssetDetail>] = [:]
    private var removedAssetDetails: [Account: Set<AssetDetail>] = [:]

    private let governanceBannerSection = 0
    private var isDisplayingBanner: Bool {
        return UIApplication.shared.rootViewController()?.isDisplayingGovernanceBanner ?? false
    }
    var isContentStateAvailableForBanner = true

    private var canDisplayGovernanceBanner: Bool {
        return isDisplayingBanner && isContentStateAvailableForBanner && isCurrentGovernanceStakingDate
    }

    private var isCurrentGovernanceStakingDate: Bool {
        let governanceStartDate = TimeInterval(1640361600)
        let governanceEndDate = TimeInterval(1641484800)
        let currentDate = Date().timeIntervalSince1970
        return currentDate >= governanceStartDate && currentDate <= governanceEndDate
    }
    
    var hasPendingAssetAction: Bool {
        return !addedAssetDetails.isEmpty || !removedAssetDetails.isEmpty
    }
    
    func reload() {
        guard let session = UIApplication.shared.appConfiguration?.session else {
            return
        }
        accounts = session.accounts

        configureAddedAssetDetails()
        configureRemovedAssetDetails()
    }
    
    func refresh() {
        accounts.removeAll()
        reload()
    }
    
    func add(assetDetail: AssetDetail, to account: Account) {
        guard let accountIndex = accounts.firstIndex(of: account) else {
            return
        }

        accounts[accountIndex].assetDetails.append(assetDetail)
        if addedAssetDetails[account] == nil {
            addedAssetDetails[account] = [assetDetail]
        } else {
            addedAssetDetails[account]?.insert(assetDetail)
        }
    }
    
    func remove(assetDetail: AssetDetail, from account: Account) {
        guard let accountIndex = accounts.firstIndex(of: account),
              let idx = account.assetDetails.firstIndex(where: { $0.id == assetDetail.id }) else {
            return
        }

        account.assetDetails[idx] = assetDetail
        accounts[accountIndex] = account

        if removedAssetDetails[account] == nil {
            removedAssetDetails[account] = [assetDetail]
        } else {
            removedAssetDetails[account]?.insert(assetDetail)
        }
    }

    func account(at section: Int) -> Account? {
        if canDisplayGovernanceBanner {
            return accounts[safe: section - 1]
        }

        return accounts[safe: section]
    }
    
    func section(for account: Account) -> Int? {
        if canDisplayGovernanceBanner {
            return accounts.firstIndex(of: account)?.advanced(by: 1)
        }

        return accounts.firstIndex(of: account)
    }
    
    func item(for assetDetail: AssetDetail, in account: Account) -> Int? {
        return account.assetDetails.firstIndex(of: assetDetail)
    }
}

extension AccountsDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if canDisplayGovernanceBanner {
            return accounts.count + 1
        }

        return accounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if canDisplayGovernanceBanner && section == governanceBannerSection {
            return 1
        }

        guard let account = account(at: section),
              !account.assetDetails.isEmpty else {
            return 1
        }
        
        return account.assetDetails.count + 1
    }
}

extension AccountsDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if canDisplayGovernanceBanner && indexPath.section == governanceBannerSection {
            return dequeueBannerCell(in: collectionView, cellForItemAt: indexPath)
        }

        if indexPath.item == 0 {
            return dequeueAlgoAssetCell(in: collectionView, cellForItemAt: indexPath)
        }
        return dequeueAssetCells(in: collectionView, cellForItemAt: indexPath)
    }

    private func dequeueBannerCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GovernanceComingSoonCell.reusableIdentifier,
            for: indexPath) as? GovernanceComingSoonCell else {
                fatalError("Index path is out of bounds")
        }

        cell.delegate = self

        return cell
    }
    
    private func dequeueAlgoAssetCell(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlgoAssetCell.reusableIdentifier,
            for: indexPath) as? AlgoAssetCell else {
                fatalError("Index path is out of bounds")
        }
        
        if let account = account(at: indexPath.section) {
            cell.bind(AlgoAssetViewModel(account: account))
        }
        
        return cell
    }
    
    private func dequeueAssetCells(in collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let account = account(at: indexPath.section),
           let assetDetail = account.assetDetails[safe: indexPath.item - 1] {
            if assetDetail.isRemoved || assetDetail.isRecentlyAdded {
                let cell = layoutBuilder.dequeuePendingAssetCells(
                    in: collectionView,
                    cellForItemAt: indexPath,
                    for: assetDetail
                )
                cell.bind(PendingAssetViewModel(assetDetail: assetDetail))
                return cell
            } else {
                guard let assets = account.assets,
                    let asset = assets.first(where: { $0.id == assetDetail.id }) else {
                        fatalError("Unexpected Element")
                }
                
                let cell = layoutBuilder.dequeueAssetCells(
                    in: collectionView,
                    cellForItemAt: indexPath,
                    for: assetDetail
                )
                cell.bind(AssetViewModel(assetDetail: assetDetail, asset: asset))
                return cell
            }
        }
        
        fatalError("Index path is out of bounds")
    }
}

extension AccountsDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if canDisplayGovernanceBanner && indexPath.section == governanceBannerSection {
            return UICollectionReusableView()
        }

        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountHeaderSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountHeaderSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            if let account = account(at: indexPath.section) {
                headerView.bind(AccountHeaderSupplementaryViewModel(account: account, isActionEnabled: true))
            }
            
            headerView.delegate = self

            if canDisplayGovernanceBanner {
                headerView.tag = indexPath.section - 1
            } else {
                headerView.tag = indexPath.section
            }

            return headerView
        } else {
            guard let account = account(at: indexPath.section) else {
                fatalError("Unexpected element kind")
            }

            if account.isWatchAccount() {
                guard let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: EmptyFooterSupplementaryView.reusableIdentifier,
                    for: indexPath
                ) as? EmptyFooterSupplementaryView else {
                    fatalError("Unexpected element kind")
                }

                return footerView
            }

            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: AccountFooterSupplementaryView.reusableIdentifier,
                for: indexPath
            ) as? AccountFooterSupplementaryView else {
                fatalError("Unexpected element kind")
            }
            
            footerView.delegate = self

            if canDisplayGovernanceBanner {
                footerView.tag = indexPath.section - 1
            } else {
                footerView.tag = indexPath.section
            }

            return footerView
        }
    }
}

extension AccountsDataSource: AccountHeaderSupplementaryViewDelegate {
    func accountHeaderSupplementaryViewDidTapQRButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView) {
        if accountHeaderSupplementaryView.tag < accounts.count {
            let account = accounts[accountHeaderSupplementaryView.tag]
            delegate?.accountsDataSource(self, didTapQRButtonFor: account)
        }
    }
    
    func accountHeaderSupplementaryViewDidTapOptionsButton(_ accountHeaderSupplementaryView: AccountHeaderSupplementaryView) {
        if accountHeaderSupplementaryView.tag < accounts.count {
            let account = accounts[accountHeaderSupplementaryView.tag]
            delegate?.accountsDataSource(self, didTapOptionsButtonFor: account)
        }
    }
}

extension AccountsDataSource: AccountFooterSupplementaryViewDelegate {
    func accountFooterSupplementaryViewDidTapAddAssetButton(_ accountFooterSupplementaryView: AccountFooterSupplementaryView) {
        if accountFooterSupplementaryView.tag < accounts.count {
            let account = accounts[accountFooterSupplementaryView.tag]
            delegate?.accountsDataSource(self, didTapAddAssetButtonFor: account)
        }
    }
}

extension AccountsDataSource: GovernanceComingSoonCellDelegate {
    func governanceComingSoonCellDidTapCancelButton(_ governanceComingSoonCell: GovernanceComingSoonCell) {
        UIApplication.shared.rootViewController()?.hideGovernanceBanner()
        delegate?.accountsDataSourceDidCloseGovernance(self)
    }

    func governanceComingSoonCellDidTapGetStartedButton(_ governanceComingSoonCell: GovernanceComingSoonCell) {
        delegate?.accountsDataSourceDidGetStartedGovernance(self)
    }
}

extension AccountsDataSource {
    private func configureAddedAssetDetails() {
        // Check whether the asset is added to account in block.
        // If it's added, remove from the pending list. If it's not, add to current list again.
        for (account, addedAssets) in addedAssetDetails {
            if let index = accounts.firstIndex(of: account) {
                filterAddedAssets(at: index, for: account, in: addedAssets)
                addedAssetDetails.clearValuesIfEmpty(for: account)
            }
        }
    }

    private func filterAddedAssets(at index: Int, for account: Account, in addedAssets: Set<AssetDetail>) {
        addedAssetDetails[account] = addedAssets.filter { assetDetail -> Bool in
            let containsAssetDetailInUpdatedAccount = accounts[index].assetDetails.contains(assetDetail)

            if !containsAssetDetailInUpdatedAccount {
                accounts[index].assetDetails.append(assetDetail)
            }

            return !containsAssetDetailInUpdatedAccount
        }
    }

    private func configureRemovedAssetDetails() {
        // Check whether the asset is removed from account in block. If it's removed, remove from the pending list as well.
        for (account, removedAssets) in removedAssetDetails {
            if let index = accounts.firstIndex(of: account) {
                removedAssetDetails[account] = removedAssets.filter { !accounts[index].assetDetails.contains($0) }
                removedAssetDetails.clearValuesIfEmpty(for: account)
            }
        }
    }
}

extension AccountsDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.accountsDataSource(self, didSelectAt: indexPath)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right

        if canDisplayGovernanceBanner && indexPath.section == governanceBannerSection {
            return CGSize(width: width, height: layout.current.bannerHeight)
        }

        if indexPath.item == 0 {
            return CGSize(width: width, height: layout.current.itemHeight)
        } else {
            guard let account = account(at: indexPath.section) else {
                return .zero
            }

            let assetDetail = account.assetDetails[indexPath.item - 1]
            
            if assetDetail.hasBothDisplayName() {
                return CGSize(width: width, height: layout.current.multiItemHeight)
            } else {
                return CGSize(width: width, height: layout.current.itemHeight)
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if canDisplayGovernanceBanner && section == governanceBannerSection {
            return .zero
        }

        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.itemHeight
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if canDisplayGovernanceBanner && section == governanceBannerSection {
            return .zero
        }

        if let account = account(at: section),
           account.isWatchAccount() {
            return CGSize(
                width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
                height: layout.current.emptyFooterHeight
            )
        }

        return CGSize(
            width: UIScreen.main.bounds.width - layout.current.defaultSectionInsets.left - layout.current.defaultSectionInsets.right,
            height: layout.current.multiItemHeight
        )
    }
}

extension AccountsDataSource {
    private struct LayoutConstants: AdaptiveLayoutConstants {
        let defaultSectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
        let itemHeight: CGFloat = 52.0
        let bannerHeight: CGFloat = 190.0
        let emptyFooterHeight: CGFloat = 44.0
        let multiItemHeight: CGFloat = 72.0
    }
}

protocol AccountsDataSourceDelegate: AnyObject {
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapOptionsButtonFor account: Account)
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapAddAssetButtonFor account: Account)
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didTapQRButtonFor account: Account)
    func accountsDataSource(_ accountsDataSource: AccountsDataSource, didSelectAt indexPath: IndexPath)
    func accountsDataSourceDidGetStartedGovernance(_ accountsDataSource: AccountsDataSource)
    func accountsDataSourceDidCloseGovernance(_ accountsDataSource: AccountsDataSource)
}
