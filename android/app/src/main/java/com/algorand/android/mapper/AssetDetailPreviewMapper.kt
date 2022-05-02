/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.mapper

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.ui.AssetDetailPreview
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.extensions.hasUsdValue
import javax.inject.Inject

class AssetDetailPreviewMapper @Inject constructor() {

    fun mapToAssetDetailPreview(
        assetData: BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData,
        canSignTransaction: Boolean,
        formattedAssetBalance: String
    ): AssetDetailPreview {
        return AssetDetailPreview(
            assetId = assetData.id,
            isAlgo = assetData.isAlgo,
            isVerified = assetData.isVerified,
            fullName = AssetName.create(assetData.name),
            shortName = AssetName.createShortName(assetData.shortName),
            formattedAssetId = assetData.id.toString(),
            formattedAssetBalance = formattedAssetBalance,
            formattedAssetBalanceInCurrency = assetData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = assetData.hasUsdValue(),
            canSignTransaction = canSignTransaction
        )
    }
}
