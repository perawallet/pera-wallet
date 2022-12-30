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
import com.algorand.android.utils.MIN_FEE
import kotlinx.parcelize.Parcelize
import java.math.BigInteger

@Parcelize
sealed class TransactionData : Parcelable {

    abstract val accountCacheData: AccountCacheData
    open var calculatedFee: Long? = null
    open var transactionByteArray: ByteArray? = null
    open var amount: BigInteger = BigInteger.ZERO

    abstract fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail

    data class Send(
        override val accountCacheData: AccountCacheData,
        override var amount: BigInteger,
        val assetInformation: AssetInformation,
        val note: String? = null,
        val xnote: String? = null,
        val targetUser: TargetUser,
        var isMax: Boolean = false,
        var projectedFee: Long = MIN_FEE
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.Send(
                signedTransactionData = signedTransactionData,
                amount = amount,
                accountCacheData = accountCacheData,
                targetUser = targetUser,
                isMax = isMax,
                fee = calculatedFee ?: 0,
                assetInformation = assetInformation,
                note = note,
                xnote = xnote
            )
        }
    }

    data class AddAsset(
        override val accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation,
        val shouldWaitForConfirmation: Boolean = false
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation.AssetAddition(
                signedTransactionData = signedTransactionData,
                accountCacheData = accountCacheData,
                assetInformation = assetInformation,
                shouldWaitForConfirmation = shouldWaitForConfirmation
            )
        }
    }

    data class RemoveAsset(
        override val accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation,
        val creatorPublicKey: String
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation.AssetRemoval(
                signedTransactionData = signedTransactionData,
                accountCacheData = accountCacheData,
                assetInformation = assetInformation
            )
        }
    }

    data class SendAndRemoveAsset(
        override val accountCacheData: AccountCacheData,
        override var amount: BigInteger,
        val assetInformation: AssetInformation,
        val note: String? = null,
        val targetUser: TargetUser,
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.Send(
                signedTransactionData = signedTransactionData,
                amount = amount,
                accountCacheData = accountCacheData,
                targetUser = targetUser,
                isMax = false,
                fee = calculatedFee ?: 0,
                assetInformation = assetInformation,
                note = note
            )
        }
    }

    data class Rekey(
        override val accountCacheData: AccountCacheData,
        val rekeyAdminAddress: String,
        val ledgerDetail: Account.Detail.Ledger,
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.RekeyOperation(
                signedTransactionData,
                accountCacheData,
                rekeyAdminAddress,
                ledgerDetail
            )
        }
    }
}
