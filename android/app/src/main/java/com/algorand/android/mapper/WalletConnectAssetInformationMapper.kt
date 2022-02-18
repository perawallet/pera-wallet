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

import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class WalletConnectAssetInformationMapper @Inject constructor() {

    fun algorandMapToWalletConnectAssetInformation(
        assetInformation: AssetInformation?,
        amount: BigDecimal,
        currencySymbol: String
    ): WalletConnectAssetInformation? {
        if (assetInformation == null) return null
        return WalletConnectAssetInformation(
            assetInformation.assetId,
            assetInformation.isVerified,
            assetInformation.shortName,
            assetInformation.fullName,
            assetInformation.decimals,
            assetInformation.amount,
            amount.formatAsCurrency(currencySymbol)
        )
    }

    fun otherAssetMapToWalletConnectAssetInformation(
        assetQueryItem: AssetQueryItem?,
        assetHolding: AssetHolding?,
        amount: BigInteger,
        selectedCurrencyUsdConversionRate: BigDecimal,
        currencySymbol: String
    ): WalletConnectAssetInformation? {
        val formattedSelectedCurrencyValue = if (assetQueryItem?.usdValue != null) {
            amount.toBigDecimal()
                .movePointLeft(assetQueryItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL)
                .multiply(selectedCurrencyUsdConversionRate)
                .multiply(assetQueryItem.usdValue)
        } else {
            null
        }

        if (assetQueryItem == null) return null
        return WalletConnectAssetInformation(
            assetId = assetQueryItem.assetId,
            isVerified = assetQueryItem.isVerified,
            shortName = assetQueryItem.shortName,
            fullName = assetQueryItem.fullName,
            decimal = assetQueryItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            amount = assetHolding?.amount,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue?.formatAsCurrency(currencySymbol)
        )
    }
}
