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
        val amount: BigInteger,
        val formattedAmount: String,
        val amountInSelectedCurrency: BigDecimal,
        val formattedSelectedCurrencyValue: String,
        val isAmountInSelectedCurrencyVisible: Boolean
    ) : BaseAccountAssetData()

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
    }
}
