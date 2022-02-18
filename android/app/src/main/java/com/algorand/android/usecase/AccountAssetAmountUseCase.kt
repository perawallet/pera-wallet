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

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountAssetDataMapper
import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal.ZERO
import javax.inject.Inject

class AccountAssetAmountUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountAssetDataMapper: AccountAssetDataMapper
) {

    fun getAssetAmount(assetHolding: AssetHolding, assetItem: AssetQueryItem): BaseAccountAssetData.OwnedAssetData {
        val selectedCurrencyUsdConversionRate = algoPriceUseCase.getConversionRateOfCachedCurrency()
        val selectedCurrencySymbol = algoPriceUseCase.getCachedAlgoPrice()?.data?.symbol.orEmpty()
        val safeAssetUsdValue = assetItem.usdValue ?: ZERO
        val safeDecimal = assetItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL
        val assetAmountInSelectedCurrency = assetHolding.amount.toBigDecimal().movePointLeft(safeDecimal)
            .multiply(selectedCurrencyUsdConversionRate)
            .multiply(safeAssetUsdValue)
        return accountAssetDataMapper.mapToOwnedAssetData(
            assetQueryItem = assetItem,
            amount = assetHolding.amount,
            formattedAmount = assetHolding.amount.formatAmount(safeDecimal),
            amountInSelectedCurrency = assetAmountInSelectedCurrency,
            formattedSelectedCurrencyValue = assetAmountInSelectedCurrency.formatAsCurrency(selectedCurrencySymbol),
        )
    }
}
