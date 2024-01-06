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
//   HomeListDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class HomeListDataSource: UICollectionViewDiffableDataSource<HomeSectionIdentifier, HomeItemIdentifier> {
    init(
        _ collectionView: UICollectionView
    ) {
        super.init(collectionView: collectionView) {
            collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .empty(let item):
                switch item {
                case .loading:
                    let cell = collectionView.dequeue(
                        HomeLoadingCell.self,
                        at: indexPath
                    )
                    return cell
                case .noContent:
                    let cell = collectionView.dequeue(
                        NoContentWithActionCell.self,
                        at: indexPath
                    )
                    cell.bindData(
                        HomeNoContentViewModel()
                    )
                    return cell
                }
            case .portfolio(let item):
                switch item {
                case .portfolio(let portfolioItem):
                    let cell = collectionView.dequeue(
                        HomePortfolioCell.self,
                        at: indexPath
                    )
                    cell.bindData(portfolioItem)
                    return cell
                case .quickActions:
                    let cell = collectionView.dequeue(
                        HomeQuickActionsCell.self,
                        at: indexPath
                    )
                    return cell
                }
            case .accountNotBackedUpWarning(let item):
                let cell = collectionView.dequeue(
                    AccountNotBackedUpWarningCell.self,
                    at: indexPath
                )
                cell.bindData(item)
                return cell
            case .announcement(let item):
                switch item.type {
                case .generic, .backup:
                    let cell = collectionView.dequeue(
                        GenericAnnouncementCell.self,
                        at: indexPath
                    )
                    cell.bindData(item)
                    return cell
                case .governance:
                    let cell = collectionView.dequeue(
                        GovernanceAnnouncementCell.self,
                        at: indexPath
                    )
                    cell.bindData(item)
                    return cell
                }
            case .account(let item):
                switch item {
                case .header(let headerItem):
                    let cell = collectionView.dequeue(
                        HomeAccountsHeader.self,
                        at: indexPath
                    )
                    cell.bindData(headerItem)
                    return cell
                case .cell(let cellItem):
                    let cell = collectionView.dequeue(
                        HomeAccountCell.self,
                        at: indexPath
                    )
                    cell.bindData(cellItem)
                    return cell
                }
            }
        }

        [
            HomeLoadingCell.self,
            NoContentWithActionCell.self,
            HomePortfolioCell.self,
            HomeQuickActionsCell.self,
            AccountNotBackedUpWarningCell.self,
            GovernanceAnnouncementCell.self,
            GenericAnnouncementCell.self,
            HomeAccountsHeader.self,
            TitleWithAccessorySupplementaryCell.self,
            HomeAccountCell.self
        ].forEach {
            collectionView.register($0)
        }
    }
}
