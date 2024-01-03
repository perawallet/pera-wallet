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

package com.algorand.android.modules.swap.assetswap.ui.mapper

import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal.ZERO
import javax.inject.Inject

class SelectedAssetAmountDetailMapper @Inject constructor() {

    fun mapToSelectedAssetAmountDetail(
        amount: String?,
        formattedApproximateValue: String,
        assetDecimal: Int
    ): AssetSwapPreview.SelectedAssetAmountDetail {
        return AssetSwapPreview.SelectedAssetAmountDetail(
            amount = amount,
            formattedApproximateValue = formattedApproximateValue,
            assetDecimal = assetDecimal
        )
    }

    fun mapToDefaultSelectedAssetAmountDetail(
        amount: String? = null,
        formattedApproximateValue: String? = null,
        assetDecimal: Int? = null,
        primaryCurrencySymbol: String
    ): AssetSwapPreview.SelectedAssetAmountDetail {
        val safeFormattedAppxValue = formattedApproximateValue ?: ZERO.formatAsCurrency(primaryCurrencySymbol)
        val safeAssetDecimal = assetDecimal ?: DEFAULT_ASSET_DECIMAL
        return AssetSwapPreview.SelectedAssetAmountDetail(
            amount = amount,
            formattedApproximateValue = safeFormattedAppxValue,
            assetDecimal = safeAssetDecimal
        )
    }
}
