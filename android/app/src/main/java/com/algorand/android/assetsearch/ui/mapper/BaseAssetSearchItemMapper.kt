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

package com.algorand.android.assetsearch.ui.mapper

import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.nft.domain.model.BaseSimpleCollectible
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class BaseAssetSearchItemMapper @Inject constructor() {

    fun mapToAssetSearchItem(
        baseAssetDetail: BaseAssetDetail,
        avatarDisplayText: AssetName
    ): BaseAssetSearchListItem.AssetSearchItem {
        return BaseAssetSearchListItem.AssetSearchItem(
            assetId = baseAssetDetail.assetId,
            fullName = AssetName.create(baseAssetDetail.fullName),
            shortName = AssetName.createShortName(baseAssetDetail.shortName),
            avatarDisplayText = avatarDisplayText,
            isVerified = baseAssetDetail.isVerified
        )
    }

    fun mapToImageCollectibleSearchItem(
        baseSimpleCollectible: BaseSimpleCollectible.ImageSimpleCollectibleDetail,
        avatarDisplayText: AssetName
    ): BaseAssetSearchListItem.BaseCollectibleSearchListItem.ImageCollectibleSearchItem {
        return BaseAssetSearchListItem.BaseCollectibleSearchListItem.ImageCollectibleSearchItem(
            assetId = baseSimpleCollectible.assetId,
            fullName = AssetName.create(baseSimpleCollectible.fullName),
            shortName = AssetName.createShortName(baseSimpleCollectible.shortName),
            avatarDisplayText = avatarDisplayText,
            prismUrl = baseSimpleCollectible.prismUrl,
            isVerified = baseSimpleCollectible.isVerified
        )
    }

    fun mapToVideoCollectibleSearchItem(
        baseSimpleCollectible: BaseSimpleCollectible.VideoSimpleCollectibleDetail,
        avatarDisplayText: AssetName
    ): BaseAssetSearchListItem.BaseCollectibleSearchListItem.VideoCollectibleSearchItem {
        return BaseAssetSearchListItem.BaseCollectibleSearchListItem.VideoCollectibleSearchItem(
            assetId = baseSimpleCollectible.assetId,
            fullName = AssetName.create(baseSimpleCollectible.fullName),
            shortName = AssetName.createShortName(baseSimpleCollectible.shortName),
            avatarDisplayText = avatarDisplayText,
            thumbnailUrl = baseSimpleCollectible.thumbnailPrismUrl,
            isVerified = baseSimpleCollectible.isVerified
        )
    }

    fun mapToMixedCollectibleSearchItem(
        baseSimpleCollectible: BaseSimpleCollectible.MixedSimpleCollectibleDetail,
        avatarDisplayText: AssetName
    ): BaseAssetSearchListItem.BaseCollectibleSearchListItem.MixedCollectibleSearchItem {
        return BaseAssetSearchListItem.BaseCollectibleSearchListItem.MixedCollectibleSearchItem(
            assetId = baseSimpleCollectible.assetId,
            fullName = AssetName.create(baseSimpleCollectible.fullName),
            shortName = AssetName.createShortName(baseSimpleCollectible.shortName),
            avatarDisplayText = avatarDisplayText,
            prismUrl = baseSimpleCollectible.thumbnailPrismUrl,
            isVerified = baseSimpleCollectible.isVerified
        )
    }

    fun mapToNotSupportedCollectibleSearchItem(
        baseAssetDetail: BaseAssetDetail,
        avatarDisplayText: AssetName
    ): BaseAssetSearchListItem.BaseCollectibleSearchListItem.NotSupportedCollectibleSearchItem {
        return BaseAssetSearchListItem.BaseCollectibleSearchListItem.NotSupportedCollectibleSearchItem(
            assetId = baseAssetDetail.assetId,
            fullName = AssetName.create(baseAssetDetail.fullName),
            shortName = AssetName.createShortName(baseAssetDetail.shortName),
            avatarDisplayText = avatarDisplayText,
            isVerified = baseAssetDetail.isVerified
        )
    }
}
