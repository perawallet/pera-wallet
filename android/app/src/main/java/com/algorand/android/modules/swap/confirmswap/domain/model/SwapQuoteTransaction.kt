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

package com.algorand.android.modules.swap.confirmswap.domain.model

import android.os.Parcelable
import com.algorand.android.modules.algosdk.domain.model.RawTransaction
import com.algorand.android.modules.algosdk.domain.model.RawTransactionType.APP_TRANSACTION
import com.algorand.android.modules.algosdk.domain.model.RawTransactionType.ASSET_TRANSACTION
import com.algorand.android.modules.algosdk.domain.model.RawTransactionType.PAY_TRANSACTION
import com.algorand.android.modules.swap.utils.MAINNET_TINYMAN_ID
import com.algorand.android.modules.swap.utils.PERA_FEE_WALLET_ADDRESS
import com.algorand.android.modules.swap.utils.TESTNET_TINYMAN_ID
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import com.algorand.android.utils.flatten
import com.algorand.android.utils.isEqualTo
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class SwapQuoteTransaction : Parcelable {

    abstract val transactionGroupId: String?
    abstract val unsignedTransactions: List<UnsignedSwapSingleTransactionData>
    abstract val signedTransactions: MutableList<SignedSwapSingleTransactionData>
    abstract val transactionNodeNetworkSlug: String

    abstract val isTransactionConfirmationNeed: Boolean
    open val delayAfterConfirmation: Long? = null

    fun areTransactionsInQuoteValid(): Boolean {
        return unsignedTransactions.all { isTransactionValid(it.decodedTransaction) }
    }

    protected open fun isTransactionValid(transaction: RawTransaction?): Boolean {
        if (transaction == null) return false
        return with(transaction) {
            closeToAddress == null &&
                assetCloseToAddress == null &&
                rekeyAddress == null &&
                validTransactionTypeList.contains(transactionType)
        }
    }

    fun insertSignedTransaction(index: Int, signedSwapSingleTransactionData: SignedSwapSingleTransactionData) {
        signedTransactions[index] = signedSwapSingleTransactionData
    }

    fun getSignedTransactionsByteArray(): ByteArray? {
        return if (signedTransactions.size == 1) {
            signedTransactions.first().signedTransactionMsgPack
        } else {
            signedTransactions.map { it.signedTransactionMsgPack }.flatten()
        }
    }

    fun getTransactionsThatNeedsToBeSigned(): List<UnsignedSwapSingleTransactionData> {
        return signedTransactions.mapIndexedNotNull { index, swapSingleTransactionData ->
            if (swapSingleTransactionData.signedTransactionMsgPack == null) {
                unsignedTransactions[index]
            } else {
                null
            }
        }
    }

    companion object {
        private val validTransactionTypeList = listOf(APP_TRANSACTION, PAY_TRANSACTION, ASSET_TRANSACTION)
    }

    @Parcelize
    data class OptInTransaction(
        override val transactionGroupId: String?,
        override val unsignedTransactions: List<UnsignedSwapSingleTransactionData>,
        override val signedTransactions: MutableList<SignedSwapSingleTransactionData>,
        override val transactionNodeNetworkSlug: String
    ) : SwapQuoteTransaction() {

        override fun isTransactionValid(transaction: RawTransaction?): Boolean {
            val isAmountValid = transaction?.assetAmount?.isEqualTo(BigInteger.ZERO) ?: true
            return super.isTransactionValid(transaction) && isAmountValid
        }

        override val isTransactionConfirmationNeed: Boolean
            get() = true

        override val delayAfterConfirmation: Long
            get() = OPT_IN_CONFIRMATION_DELAY

        companion object {
            private const val OPT_IN_CONFIRMATION_DELAY = 1000L // 1 Sec
        }
    }

    @Parcelize
    data class SwapTransaction(
        override val transactionGroupId: String?,
        override val unsignedTransactions: List<UnsignedSwapSingleTransactionData>,
        override val signedTransactions: MutableList<SignedSwapSingleTransactionData>,
        override val transactionNodeNetworkSlug: String
    ) : SwapQuoteTransaction() {
        override val isTransactionConfirmationNeed: Boolean
            get() = true

        override fun isTransactionValid(transaction: RawTransaction?): Boolean {
            val areGroupIdsSame = unsignedTransactions.all { it.decodedTransaction?.groupId == transactionGroupId }
            return super.isTransactionValid(transaction) && areGroupIdsSame && isAppIdValid(transaction)
        }

        private fun isAppIdValid(transaction: RawTransaction?): Boolean {
            if (transaction?.transactionType != APP_TRANSACTION) return true
            return when (transactionNodeNetworkSlug) {
                TESTNET_NETWORK_SLUG -> transaction.appId == TESTNET_TINYMAN_ID
                MAINNET_NETWORK_SLUG -> transaction.appId == MAINNET_TINYMAN_ID
                else -> false
            }
        }
    }

    @Parcelize
    data class PeraFeeTransaction(
        override val transactionGroupId: String?,
        override val unsignedTransactions: List<UnsignedSwapSingleTransactionData>,
        override val signedTransactions: MutableList<SignedSwapSingleTransactionData>,
        override val transactionNodeNetworkSlug: String
    ) : SwapQuoteTransaction() {
        override val isTransactionConfirmationNeed: Boolean
            get() = false

        override fun isTransactionValid(transaction: RawTransaction?): Boolean {
            val receiverAddress = transaction?.receiverAddress?.decodedAddress
            return super.isTransactionValid(transaction) && receiverAddress == PERA_FEE_WALLET_ADDRESS
        }
    }

    @Parcelize
    object InvalidTransaction : SwapQuoteTransaction() {
        override val transactionGroupId: String?
            get() = null
        override val unsignedTransactions: List<UnsignedSwapSingleTransactionData>
            get() = emptyList()
        override val signedTransactions: MutableList<SignedSwapSingleTransactionData>
            get() = emptyList<SignedSwapSingleTransactionData>().toMutableList()
        override val transactionNodeNetworkSlug: String
            get() = ""
        override val isTransactionConfirmationNeed: Boolean
            get() = false

        override fun isTransactionValid(transaction: RawTransaction?): Boolean {
            return false
        }
    }
}
