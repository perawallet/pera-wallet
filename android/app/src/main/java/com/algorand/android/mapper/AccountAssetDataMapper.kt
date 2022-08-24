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

import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.ALGO_FULL_NAME
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.isNotEqualTo
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class AccountAssetDataMapper @Inject constructor() {

    fun mapToOwnedAssetData(
        assetDetail: AssetDetail,
        amount: BigInteger,
        formattedAmount: String,
        formattedCompactAmount: String,
        parityValueInSelectedCurrency: ParityValue,
        parityValueInSecondaryCurrency: ParityValue
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        return BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData(
            id = assetDetail.assetId,
            name = assetDetail.fullName,
            shortName = assetDetail.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            formattedCompactAmount = formattedCompactAmount,
            isVerified = assetDetail.isVerified,
            isAlgo = false,
            decimals = assetDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetDetail.assetCreator?.publicKey,
            usdValue = assetDetail.usdValue,
            isAmountInSelectedCurrencyVisible = assetDetail.usdValue != null && amount isNotEqualTo BigInteger.ZERO,
            parityValueInSelectedCurrency = parityValueInSelectedCurrency,
            parityValueInSecondaryCurrency = parityValueInSecondaryCurrency
        )
    }

    fun mapToPendingAdditionAssetData(assetDetail: BaseAssetDetail): BaseAccountAssetData {
        return BaseAccountAssetData.PendingAssetData.AdditionAssetData(
            id = assetDetail.assetId,
            name = assetDetail.fullName,
            shortName = assetDetail.shortName,
            isVerified = assetDetail.isVerified,
            isAlgo = false,
            decimals = assetDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetDetail.assetCreator?.publicKey,
            usdValue = assetDetail.usdValue
        )
    }

    fun mapToPendingRemovalAssetData(assetDetail: BaseAssetDetail): BaseAccountAssetData {
        return BaseAccountAssetData.PendingAssetData.DeletionAssetData(
            id = assetDetail.assetId,
            name = assetDetail.fullName,
            shortName = assetDetail.shortName,
            isVerified = assetDetail.isVerified,
            isAlgo = false,
            decimals = assetDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = assetDetail.assetCreator?.publicKey,
            usdValue = assetDetail.usdValue
        )
    }

    fun mapToAlgoAssetData(
        amount: BigInteger,
        parityValueInSelectedCurrency: ParityValue,
        parityValueInSecondaryCurrency: ParityValue,
        usdValue: BigDecimal
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        return BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData(
            id = ALGO_ID,
            name = ALGO_FULL_NAME,
            shortName = ALGO_SHORT_NAME,
            amount = amount,
            formattedAmount = amount.formatAmount(ALGO_DECIMALS).formatAsAlgoAmount(),
            formattedCompactAmount = amount.formatAmount(ALGO_DECIMALS, isCompact = true).formatAsAlgoAmount(),
            isVerified = true,
            isAlgo = true,
            decimals = ALGO_DECIMALS,
            creatorPublicKey = "",
            usdValue = usdValue,
            isAmountInSelectedCurrencyVisible = true, // Algo always has a currency value
            parityValueInSelectedCurrency = parityValueInSelectedCurrency,
            parityValueInSecondaryCurrency = parityValueInSecondaryCurrency
        )
    }
}
