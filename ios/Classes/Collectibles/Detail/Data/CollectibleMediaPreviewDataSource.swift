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

//   CollectibleMediaPreviewDataSource.swift

import Foundation
import MacaroonUIKit
import UIKit

final class CollectibleMediaPreviewDataSource:
    NSObject,
    UICollectionViewDataSource {
    private let theme: CollectibleMediaPreviewViewController.Theme
    private let asset: CollectibleAsset
    var accountCollectibleStatus: AccountCollectibleStatus

    init(
        theme: CollectibleMediaPreviewViewController.Theme,
        asset: CollectibleAsset,
        accountCollectibleStatus: AccountCollectibleStatus
    ) {
        self.theme = theme
        self.asset = asset
        self.accountCollectibleStatus = accountCollectibleStatus
    }
}

extension CollectibleMediaPreviewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if asset.media.isEmpty {
            return 1
        }

        return asset.media.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let width = collectionView.bounds.width - theme.horizontalInset * 2

        if asset.media.isEmpty {
            let cell = collectionView.dequeue(
                CollectibleMediaImagePreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaStandardImagePreviewViewModel(
                    imageSize: CGSize((width.float(), width.float())),
                    asset: asset,
                    accountCollectibleStatus: accountCollectibleStatus,
                    media: nil
                )
            )

            return cell
        }

        guard let media = asset.media[safe: indexPath.item] else {
            fatalError("Could not find the related media.")
        }

        switch media.type {
        case .audio:
            let cell = collectionView.dequeue(
                CollectibleMediaAudioPreviewCell.self,
                at: indexPath
            )
            
            cell.bindData(
                CollectibleMediaAudioPreviewViewModel(
                    asset: asset,
                    accountCollectibleStatus: accountCollectibleStatus,
                    media: media
                )
            )
            
            return cell
        case .image:
            let cell = collectionView.dequeue(
                CollectibleMediaImagePreviewCell.self,
                at: indexPath
            )

            switch media.mediaExtension {
            case .gif:
                cell.bindData(
                    CollectibleMediaGIFPreviewViewModel(
                        imageSize: CGSize((width.float(), width.float())),
                        asset: asset,
                        accountCollectibleStatus: accountCollectibleStatus,
                        media: media
                    )
                )
            case .webp:
                cell.bindData(
                    CollectibleMediaWebPImagePreviewViewModel(
                        imageSize: CGSize((width.float(), width.float())),
                        asset: asset,
                        accountCollectibleStatus: accountCollectibleStatus,
                        media: media
                    )
                )
            default:
                cell.bindData(
                    CollectibleMediaStandardImagePreviewViewModel(
                        imageSize: CGSize((width.float(), width.float())),
                        asset: asset,
                        accountCollectibleStatus: accountCollectibleStatus,
                        media: media
                    )
                )
            }

            return cell
        case .video:
            let cell = collectionView.dequeue(
                CollectibleMediaVideoPreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaVideoPreviewViewModel(
                    asset: asset,
                    accountCollectibleStatus: accountCollectibleStatus,
                    media: media
                )
            )

            return cell
        default:
            let cell = collectionView.dequeue(
                CollectibleMediaImagePreviewCell.self,
                at: indexPath
            )

            cell.bindData(
                CollectibleMediaStandardImagePreviewViewModel(
                    imageSize: CGSize((width.float(), width.float())),
                    asset: asset,
                    accountCollectibleStatus: accountCollectibleStatus,
                    media: nil
                )
            )

            return cell
        }
    }
}
