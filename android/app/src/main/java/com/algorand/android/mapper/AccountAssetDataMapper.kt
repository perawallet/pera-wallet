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

import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.extensions.hasUsdValue
import com.algorand.android.utils.formatAmount
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class AccountAssetDataMapper @Inject constructor() {

    fun mapToOwnedAssetData(
        assetQueryItem: AssetQueryItem,
        amount: BigInteger,
        formattedAmount: String,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String
    ): BaseAccountAssetData.OwnedAssetData {
        return BaseAccountAssetData.OwnedAssetData(
            id = assetQueryItem.assetId,
            name = assetQueryItem.fullName,
            shortName = assetQueryItem.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            isVerified = assetQueryItem.isVerified,
            isAlgo = false,
            decimals = assetQueryItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetQueryItem.assetCreator?.publicKey,
            usdValue = assetQueryItem.usdValue,
            isAmountInSelectedCurrencyVisible = assetQueryItem.hasUsdValue()
        )
    }

    fun mapToPendingAdditionAssetData(assetQueryItem: AssetQueryItem): BaseAccountAssetData {
        return BaseAccountAssetData.PendingAssetData.AdditionAssetData(
            id = assetQueryItem.assetId,
            name = assetQueryItem.fullName,
            shortName = assetQueryItem.shortName,
            isVerified = assetQueryItem.isVerified,
            isAlgo = false,
            decimals = assetQueryItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetQueryItem.assetCreator?.publicKey,
            usdValue = assetQueryItem.usdValue
        )
    }

    fun mapToPendingRemovalAssetData(assetQueryItem: AssetQueryItem): BaseAccountAssetData {
        return BaseAccountAssetData.PendingAssetData.DeletionAssetData(
            id = assetQueryItem.assetId,
            name = assetQueryItem.fullName,
            shortName = assetQueryItem.shortName,
            isVerified = assetQueryItem.isVerified,
            isAlgo = false,
            decimals = assetQueryItem.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetQueryItem.assetCreator?.publicKey,
            usdValue = assetQueryItem.usdValue
        )
    }

    fun mapToAlgoAssetData(
        amount: BigInteger,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String,
        usdValue: BigDecimal
    ): BaseAccountAssetData.OwnedAssetData {
        return BaseAccountAssetData.OwnedAssetData(
            id = ALGORAND_ID,
            name = "Algo", // TODO Get these from constants
            shortName = "ALGO",
            amount = amount,
            formattedAmount = amount.formatAmount(ALGO_DECIMALS),
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            isVerified = true,
            isAlgo = true,
            decimals = ALGO_DECIMALS,
            creatorPublicKey = "", // TODO set creator public key
            usdValue = usdValue,
            isAmountInSelectedCurrencyVisible = true // Algo always has a currency value
        )
    }
}
