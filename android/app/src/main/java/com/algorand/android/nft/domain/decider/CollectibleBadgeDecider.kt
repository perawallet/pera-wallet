/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.nft.domain.decider

import com.algorand.android.R
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionVideoCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionVideoCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingVideoCollectibleData
import javax.inject.Inject

class CollectibleBadgeDecider @Inject constructor() {

    fun decideCollectibleBadgeResId(ownedCollectibleData: BaseOwnedCollectibleData): Int? {
        return when (ownedCollectibleData) {
            is OwnedCollectibleImageData -> null
            is OwnedCollectibleVideoData -> getVideoBadgeResId()
            is OwnedUnsupportedCollectibleData -> getUnsupportedBadgeResId()
            is OwnedCollectibleMixedData -> getMixedBadgeResId()
        }
    }

    fun decidePendingCollectibleBadgeResId(pendingCollectibleData: BasePendingCollectibleData): Int? {
        return when (pendingCollectibleData) {
            is AdditionImageCollectibleData, is DeletionImageCollectibleData, is SendingImageCollectibleData -> {
                null
            }
            is AdditionVideoCollectibleData, is DeletionVideoCollectibleData, is SendingVideoCollectibleData -> {
                getVideoBadgeResId()
            }
            is AdditionMixedCollectibleData, is DeletionMixedCollectibleData, is SendingMixedCollectibleData -> {
                getMixedBadgeResId()
            }
            is AdditionUnsupportedCollectibleData, is DeletionUnsupportedCollectibleData,
            is SendingUnsupportedCollectibleData -> {
                getUnsupportedBadgeResId()
            }
        }
    }

    private fun getVideoBadgeResId(): Int = R.drawable.ic_badge_video

    private fun getMixedBadgeResId(): Int = R.drawable.ic_badge_mixed

    private fun getUnsupportedBadgeResId(): Int = R.drawable.ic_badge_unsupported
}
