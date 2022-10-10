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

import androidx.annotation.StringRes
import com.algorand.android.assetsearch.domain.model.BaseSearchedAsset
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class BaseAssetSearchItemMapper @Inject constructor(
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider
) {

    fun mapToAssetSearchItem(
        searchedAsset: BaseSearchedAsset.SearchedAsset,
        accountAssetItemButtonState: AccountAssetItemButtonState
    ): BaseAssetSearchListItem.AssetListItem.AssetSearchItem {
        return BaseAssetSearchListItem.AssetListItem.AssetSearchItem(
            assetId = searchedAsset.assetId,
            fullName = AssetName.create(searchedAsset.fullName),
            shortName = AssetName.createShortName(searchedAsset.shortName),
            verificationTierConfiguration = verificationTierConfigurationDecider.decideVerificationTierConfiguration(
                searchedAsset.verificationTier
            ),
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(searchedAsset),
            prismUrl = searchedAsset.logo,
            accountAssetItemButtonState = accountAssetItemButtonState
        )
    }

    fun mapToCollectibleSearchItem(
        searchedCollectible: BaseSearchedAsset.SearchedCollectible,
        accountAssetItemButtonState: AccountAssetItemButtonState
    ): BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem.ImageCollectibleSearchItem {
        return BaseAssetSearchListItem.AssetListItem.BaseCollectibleSearchListItem.ImageCollectibleSearchItem(
            assetId = searchedCollectible.assetId,
            fullName = AssetName.create(searchedCollectible.fullName),
            shortName = AssetName.createShortName(searchedCollectible.shortName),
            prismUrl = searchedCollectible.collectible?.primaryImageUrl,
            accountAssetItemButtonState = accountAssetItemButtonState,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(searchedCollectible)
        )
    }

    fun mapToInfoViewItem(@StringRes infoViewTextResId: Int): BaseAssetSearchListItem.InfoViewItem {
        return BaseAssetSearchListItem.InfoViewItem(infoViewTextResId = infoViewTextResId)
    }

    fun mapToSearchViewItem(@StringRes searchViewHintResId: Int): BaseAssetSearchListItem.SearchViewItem {
        return BaseAssetSearchListItem.SearchViewItem(searchViewHintResId = searchViewHintResId)
    }
}
