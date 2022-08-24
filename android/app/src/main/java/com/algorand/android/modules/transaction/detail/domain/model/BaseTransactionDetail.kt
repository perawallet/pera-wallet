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

package com.algorand.android.modules.transaction.detail.domain.model

import android.os.Parcelable
import com.algorand.android.R
import com.algorand.android.modules.transaction.common.domain.model.OnCompletionDTO
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseTransactionDetail : Parcelable {

    abstract val id: String?
    abstract val signature: String?
    abstract val senderAccountAddress: String?
    abstract val receiverAccountAddress: String?
    abstract val roundTimeAsTimestamp: Long?
    abstract val fee: BigInteger
    abstract val noteInBase64: String?

    abstract val closeToAccountAddress: String?
    abstract val transactionCloseAmount: BigInteger?
    abstract val transactionAmount: BigInteger?

    abstract val toolbarTitleResId: Int

    @Parcelize
    data class PaymentTransaction(
        override val id: String?,
        override val signature: String?,
        override val senderAccountAddress: String?,
        override val receiverAccountAddress: String?,
        override val roundTimeAsTimestamp: Long?,
        override val fee: BigInteger,
        override val noteInBase64: String?,
        override val closeToAccountAddress: String?,
        override val transactionCloseAmount: BigInteger?,
        override val transactionAmount: BigInteger
    ) : BaseTransactionDetail() {

        override val toolbarTitleResId: Int
            get() = R.string.transaction_detail
    }

    @Parcelize
    data class AssetTransferTransaction(
        override val id: String?,
        override val signature: String?,
        override val senderAccountAddress: String?,
        override val receiverAccountAddress: String?,
        override val roundTimeAsTimestamp: Long?,
        override val fee: BigInteger,
        override val noteInBase64: String?,
        override val closeToAccountAddress: String?,
        override val transactionCloseAmount: BigInteger?,
        override val transactionAmount: BigInteger,
        val assetId: Long
    ) : BaseTransactionDetail() {
        override val toolbarTitleResId: Int
            get() = R.string.transaction_detail
    }

    @Parcelize
    data class AssetConfigurationTransaction(
        override val id: String?,
        override val signature: String?,
        override val senderAccountAddress: String?,
        override val receiverAccountAddress: String?,
        override val roundTimeAsTimestamp: Long?,
        override val fee: BigInteger,
        override val noteInBase64: String?,
        override val closeToAccountAddress: String? = null,
        override val transactionCloseAmount: BigInteger? = null,
        override val transactionAmount: BigInteger? = null,
        val name: String?,
        val unitName: String?,
        val assetId: Long?,
    ) : BaseTransactionDetail() {
        override val toolbarTitleResId: Int
            get() = R.string.asset_configuration
    }

    @Parcelize
    data class ApplicationCallTransaction(
        override val id: String?,
        override val signature: String?,
        override val senderAccountAddress: String?,
        override val receiverAccountAddress: String? = null,
        override val roundTimeAsTimestamp: Long?,
        override val fee: BigInteger,
        override val noteInBase64: String?,
        override val closeToAccountAddress: String? = null,
        override val transactionCloseAmount: BigInteger? = null,
        override val transactionAmount: BigInteger? = null,
        val innerTransactions: List<BaseTransactionDetail>?,
        val innerTransactionCount: Int,
        val onCompletion: OnCompletionDTO?,
        val applicationId: Long?,
        val foreignAssetIds: List<Long>?
    ) : BaseTransactionDetail() {

        override val toolbarTitleResId: Int
            get() = R.string.app_call

        fun hasInnerTransaction(): Boolean {
            return innerTransactionCount > 0
        }
    }

    @Parcelize
    data class UndefinedTransaction(
        override val id: String? = null,
        override val signature: String? = null,
        override val senderAccountAddress: String? = null,
        override val receiverAccountAddress: String? = null,
        override val roundTimeAsTimestamp: Long? = null,
        override val fee: BigInteger = BigInteger.ZERO,
        override val noteInBase64: String? = null,
        override val closeToAccountAddress: String? = null,
        override val transactionCloseAmount: BigInteger? = null,
        override val transactionAmount: BigInteger? = null
    ) : BaseTransactionDetail() {

        override val toolbarTitleResId: Int
            get() = R.string.transaction_detail
    }
}
