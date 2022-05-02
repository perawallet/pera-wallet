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

import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData.AdditionVideoCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData.DeletionVideoCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingImageCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingMixedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData.SendingVideoCollectibleData
import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class AccountCollectibleDataMapper @Inject constructor() {

    fun mapToOwnedCollectibleImageData(
        collectibleDetail: SimpleCollectibleDetail,
        amount: BigInteger,
        formattedAmount: String,
        formattedCompactAmount: String,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String,
        formattedSelectedCurrencyCompactValue: String
    ): OwnedCollectibleImageData {
        return OwnedCollectibleImageData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            formattedCompactAmount = formattedCompactAmount,
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            formattedSelectedCurrencyCompactValue = formattedSelectedCurrencyCompactValue,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            isAmountInSelectedCurrencyVisible = collectibleDetail.hasUsdValue(),
            prismUrl = collectibleDetail.collectible.primaryImageUrl,
            collectibleName = collectibleDetail.collectible.title,
            collectionName = collectibleDetail.collectible.collectionName
        )
    }

    fun mapToOwnedCollectibleVideoData(
        collectibleDetail: SimpleCollectibleDetail,
        amount: BigInteger,
        formattedAmount: String,
        formattedCompactAmount: String,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String,
        formattedSelectedCurrencyCompactValue: String
    ): OwnedCollectibleVideoData {
        return OwnedCollectibleVideoData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            formattedCompactAmount = formattedCompactAmount,
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            formattedSelectedCurrencyCompactValue = formattedSelectedCurrencyCompactValue,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            isAmountInSelectedCurrencyVisible = collectibleDetail.hasUsdValue(),
            thumbnailPrismUrl = collectibleDetail.collectible.primaryImageUrl,
            collectibleName = collectibleDetail.collectible.title,
            collectionName = collectibleDetail.collectible.collectionName
        )
    }

    fun mapToOwnedCollectibleMixedData(
        collectibleDetail: SimpleCollectibleDetail,
        amount: BigInteger,
        formattedAmount: String,
        formattedCompactAmount: String,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String,
        formattedSelectedCurrencyCompactValue: String
    ): OwnedCollectibleMixedData {
        return OwnedCollectibleMixedData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            formattedCompactAmount = formattedCompactAmount,
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            formattedSelectedCurrencyCompactValue = formattedSelectedCurrencyCompactValue,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            isAmountInSelectedCurrencyVisible = collectibleDetail.hasUsdValue(),
            thumbnailPrismUrl = collectibleDetail.collectible.primaryImageUrl,
            collectibleName = collectibleDetail.collectible.title,
            collectionName = collectibleDetail.collectible.collectionName
        )
    }

    fun mapToNotSupportedOwnedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail,
        amount: BigInteger,
        formattedAmount: String,
        formattedCompactAmount: String,
        amountInSelectedCurrency: BigDecimal,
        formattedSelectedCurrencyValue: String,
        formattedSelectedCurrencyCompactValue: String
    ): OwnedUnsupportedCollectibleData {
        return OwnedUnsupportedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            amount = amount,
            formattedAmount = formattedAmount,
            formattedCompactAmount = formattedCompactAmount,
            amountInSelectedCurrency = amountInSelectedCurrency,
            formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
            formattedSelectedCurrencyCompactValue = formattedSelectedCurrencyCompactValue,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            isAmountInSelectedCurrencyVisible = collectibleDetail.hasUsdValue(),
            collectibleName = collectibleDetail.collectible.title,
            collectionName = collectibleDetail.collectible.collectionName
        )
    }

    fun mapToPendingRemovalImageCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingDeletionCollectibleData {
        return DeletionImageCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingRemovalVideoCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingDeletionCollectibleData {
        return DeletionVideoCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingRemovalUnsupportedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingDeletionCollectibleData {
        return DeletionUnsupportedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingRemovalMixedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): DeletionMixedCollectibleData {
        return DeletionMixedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingAdditionImageCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingAdditionCollectibleData {
        return AdditionImageCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingAdditionVideoCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingAdditionCollectibleData {
        return AdditionVideoCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingAdditionUnsupportedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingAdditionCollectibleData {
        return AdditionUnsupportedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingAdditionMixedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingAdditionCollectibleData {
        return AdditionMixedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingSendingImageCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingSendingCollectibleData {
        return SendingImageCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingSendingVideoCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingSendingCollectibleData {
        return SendingVideoCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingSendingUnsupportedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingSendingCollectibleData {
        return SendingUnsupportedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }

    fun mapToPendingSendingMixedCollectibleData(
        collectibleDetail: SimpleCollectibleDetail
    ): PendingSendingCollectibleData {
        return SendingMixedCollectibleData(
            id = collectibleDetail.assetId,
            name = collectibleDetail.fullName,
            shortName = collectibleDetail.shortName,
            isVerified = collectibleDetail.isVerified,
            isAlgo = false,
            decimals = collectibleDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL,
            creatorPublicKey = collectibleDetail.assetCreator?.publicKey,
            usdValue = collectibleDetail.usdValue,
            primaryImageUrl = collectibleDetail.collectible.primaryImageUrl,
            collectionName = collectibleDetail.collectible.collectionName,
            collectibleName = collectibleDetail.collectible.title
        )
    }
}
