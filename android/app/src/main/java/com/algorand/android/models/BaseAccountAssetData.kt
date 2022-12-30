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
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.utils.isGreaterThan
import java.math.BigDecimal
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseAccountAssetData : Parcelable {

    abstract val id: Long
    abstract val name: String?
    abstract val shortName: String?
    abstract val isAlgo: Boolean
    abstract val decimals: Int
    abstract val creatorPublicKey: String?
    abstract val usdValue: BigDecimal?
    abstract val verificationTier: VerificationTier?
    abstract val optedInAtRound: Long?

    sealed class BaseOwnedAssetData : BaseAccountAssetData() {
        abstract val amount: BigInteger
        abstract val formattedAmount: String
        abstract val formattedCompactAmount: String
        abstract val parityValueInSelectedCurrency: ParityValue
        abstract val parityValueInSecondaryCurrency: ParityValue
        abstract val isAmountInSelectedCurrencyVisible: Boolean
        abstract val prismUrl: String?

        fun getSelectedCurrencyParityValue(): ParityValue {
            return if (isAlgo && parityValueInSelectedCurrency.selectedCurrencySymbol == Currency.ALGO.symbol) {
                parityValueInSecondaryCurrency
            } else {
                parityValueInSelectedCurrency
            }
        }

        @Parcelize
        data class OwnedAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            override val parityValueInSelectedCurrency: ParityValue,
            override val parityValueInSecondaryCurrency: ParityValue,
            override val prismUrl: String?,
            override val verificationTier: VerificationTier,
            override val optedInAtRound: Long?
        ) : BaseOwnedAssetData()

        sealed class BaseOwnedCollectibleData : BaseOwnedAssetData() {

            abstract val collectibleName: String?
            abstract val collectionName: String?

            val isOwnedByTheUser: Boolean get() = amount isGreaterThan BigInteger.ZERO

            override val verificationTier: VerificationTier?
                get() = null

            @Parcelize
            data class OwnedCollectibleImageData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val parityValueInSelectedCurrency: ParityValue,
                override val parityValueInSecondaryCurrency: ParityValue,
                override val prismUrl: String?,
                override val optedInAtRound: Long?
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedCollectibleVideoData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val parityValueInSelectedCurrency: ParityValue,
                override val parityValueInSecondaryCurrency: ParityValue,
                override val prismUrl: String?,
                override val optedInAtRound: Long?,
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedCollectibleAudioData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val parityValueInSelectedCurrency: ParityValue,
                override val parityValueInSecondaryCurrency: ParityValue,
                override val prismUrl: String?,
                override val optedInAtRound: Long?,
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedCollectibleMixedData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val parityValueInSelectedCurrency: ParityValue,
                override val parityValueInSecondaryCurrency: ParityValue,
                override val prismUrl: String?,
                override val optedInAtRound: Long?,
            ) : BaseOwnedCollectibleData()

            @Parcelize
            data class OwnedUnsupportedCollectibleData(
                override val id: Long,
                override val name: String?,
                override val shortName: String?,
                override val isAlgo: Boolean,
                override val decimals: Int,
                override val creatorPublicKey: String?,
                override val usdValue: BigDecimal?,
                override val amount: BigInteger,
                override val formattedAmount: String,
                override val formattedCompactAmount: String,
                override val isAmountInSelectedCurrencyVisible: Boolean,
                override val collectibleName: String?,
                override val collectionName: String?,
                override val parityValueInSelectedCurrency: ParityValue,
                override val parityValueInSecondaryCurrency: ParityValue,
                override val prismUrl: String?,
                override val optedInAtRound: Long?
            ) : BaseOwnedCollectibleData()
        }
    }

    sealed class PendingAssetData : BaseAccountAssetData() {

        override val optedInAtRound: Long? = null

        @Parcelize
        data class DeletionAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?,
            override val verificationTier: VerificationTier
        ) : PendingAssetData()

        @Parcelize
        data class AdditionAssetData(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val usdValue: BigDecimal?,
            override val verificationTier: VerificationTier
        ) : PendingAssetData()

        sealed class BasePendingCollectibleData : PendingAssetData() {

            abstract val collectibleName: String?
            abstract val collectionName: String?
            abstract val primaryImageUrl: String?

            val avatarDisplayText: String
                get() = collectibleName ?: name ?: shortName ?: id.toString()

            override val verificationTier: VerificationTier?
                get() = null

            sealed class PendingAdditionCollectibleData : BasePendingCollectibleData() {

                @Parcelize
                data class AdditionImageCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
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
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingAdditionCollectibleData()

                @Parcelize
                data class AdditionAudioCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
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
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingDeletionCollectibleData()

                @Parcelize
                data class DeletionAudioCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
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
                    override val isAlgo: Boolean,
                    override val decimals: Int,
                    override val creatorPublicKey: String?,
                    override val usdValue: BigDecimal?,
                    override val collectibleName: String?,
                    override val collectionName: String?,
                    override val primaryImageUrl: String?
                ) : PendingSendingCollectibleData()

                @Parcelize
                data class SendingAudioCollectibleData(
                    override val id: Long,
                    override val name: String?,
                    override val shortName: String?,
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
