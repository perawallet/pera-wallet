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

package com.algorand.android.models

import android.os.Parcelable
import java.math.BigDecimal
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseAccountAssetData : Parcelable {

    abstract val id: Long
    abstract val name: String?
    abstract val shortName: String?
    abstract val isVerified: Boolean
    abstract val isAlgo: Boolean
    abstract val decimals: Int
    abstract val creatorPublicKey: String?
    abstract val usdValue: BigDecimal?

    sealed class BaseOwnedAssetData : BaseAccountAssetData() {
        abstract val amount: BigInteger
        abstract val formattedAmount: String
        abstract val amountInSelectedCurrency: BigDecimal
        abstract val formattedSelectedCurrencyValue: String
        abstract val isAmountInSelectedCurrencyVisible: Boolean

        @Parcelize
        data class OwnedAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val amountInSelectedCurrency: BigDecimal,
            override val formattedSelectedCurrencyValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
        ) : BaseOwnedAssetData()

        sealed class BaseOwnedCollectibleData : BaseOwnedAssetData() {

            abstract val collectibleName: String?
            abstract val collectionName: String?

            @Parcelize
            data class OwnedCollectibleImageData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val amountInSelectedCurrency: BigDecimal,
                override val formattedSelectedCurrencyValue: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                val prismUrl: String?
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedCollectibleVideoData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val amountInSelectedCurrency: BigDecimal,
                override val formattedSelectedCurrencyValue: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                val thumbnailPrismUrl: String?
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedCollectibleMixedData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val amountInSelectedCurrency: BigDecimal,
                override val formattedSelectedCurrencyValue: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                val thumbnailPrismUrl: String?
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedUnsupportedCollectibleData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isVerified: Boolean,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val amountInSelectedCurrency: BigDecimal,
                override val formattedSelectedCurrencyValue: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
            ) : BaseOwnedCollectibleData()
        }
    }

    sealed class PendingAssetData : BaseAccountAssetData() {

        @Parcelize
        data class DeletionAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?
        ) : PendingAssetData()

        @Parcelize
        data class AdditionAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?
        ) : PendingAssetData()

        sealed class BasePendingCollectibleData : BaseAccountAssetData() {

            abstract val collectibleName: String?
            abstract val collectionName: String?
            abstract val primaryImageUrl: String?

            sealed class PendingAdditionCollectibleData : BasePendingCollectibleData() {

                @Parcelize
                data class AdditionImageCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingAdditionCollectibleData()

                @Parcelize
                data class AdditionVideoCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingAdditionCollectibleData()

                @Parcelize
                data class AdditionUnsupportedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingAdditionCollectibleData()

                @Parcelize
                data class AdditionMixedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingAdditionCollectibleData()
            }

            sealed class PendingDeletionCollectibleData : BasePendingCollectibleData() {

                @Parcelize
                data class DeletionImageCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingDeletionCollectibleData()

                @Parcelize
                data class DeletionVideoCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingDeletionCollectibleData()

                @Parcelize
                data class DeletionUnsupportedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingDeletionCollectibleData()

                @Parcelize
                data class DeletionMixedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingDeletionCollectibleData()
            }

            sealed class PendingSendingCollectibleData : BasePendingCollectibleData() {

                @Parcelize
                data class SendingImageCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingSendingCollectibleData()

                @Parcelize
                data class SendingVideoCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingSendingCollectibleData()

                @Parcelize
                data class SendingUnsupportedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingSendingCollectibleData()

                @Parcelize
                data class SendingMixedCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
                    override val isVerified: Boolean,
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingSendingCollectibleData()
            }
        }
    }
}
