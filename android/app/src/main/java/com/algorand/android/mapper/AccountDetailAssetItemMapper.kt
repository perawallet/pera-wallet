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

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.AccountDetailAssetsItem.BaseAssetItem.BasePendingAssetItem.PendingAdditionItem
import com.algorand.android.models.AccountDetailAssetsItem.BaseAssetItem.BasePendingAssetItem.PendingRemovalItem
import com.algorand.android.models.BaseAccountAssetData.OwnedAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.hasUsdValue
import javax.inject.Inject

// TODO Rename this function to make it screen independent
class AccountDetailAssetItemMapper @Inject constructor() {

    fun mapToOwnedAssetItem(accountAssetData: OwnedAssetData): AccountDetailAssetsItem.BaseAssetItem.OwnedAssetItem {
        return AccountDetailAssetsItem.BaseAssetItem.OwnedAssetItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            formattedAmount = accountAssetData.formattedAmount,
            formattedSelectedCurrencyValue = accountAssetData.formattedSelectedCurrencyValue,
            isVerified = accountAssetData.isVerified,
            isAlgo = accountAssetData.isAlgo,
            isAmountInSelectedCurrencyVisible = accountAssetData.hasUsdValue()
        )
    }

    fun mapToPendingAdditionAssetItem(accountAssetData: PendingAssetData.AdditionAssetData): PendingAdditionItem {
        return PendingAdditionItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            isVerified = accountAssetData.isVerified,
            isAlgo = accountAssetData.isAlgo,
            actionDescriptionResId = R.string.adding_asset
        )
    }

    fun mapToPendingRemovalAssetItem(accountAssetData: PendingAssetData.DeletionAssetData): PendingRemovalItem {
        return PendingRemovalItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            isVerified = accountAssetData.isVerified,
            isAlgo = accountAssetData.isAlgo,
            actionDescriptionResId = R.string.removing_asset
        )
    }
}
