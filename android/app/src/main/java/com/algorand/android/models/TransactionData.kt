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
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
sealed class TransactionData : Parcelable {

    abstract val senderAccountAddress: String
    abstract val senderAccountType: Account.Type?
    abstract val senderAuthAddress: String?
    abstract val isSenderRekeyedToAnotherAccount: Boolean
    abstract val senderAccountDetail: Account.Detail?

    open var calculatedFee: Long? = null
    open var transactionByteArray: ByteArray? = null
    open var amount: BigInteger = BigInteger.ZERO

    abstract fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail

    data class Send(
        override val senderAccountAddress: String,
        override val senderAuthAddress: String?,
        override val isSenderRekeyedToAnotherAccount: Boolean,
        override val senderAccountType: Account.Type?,
        override val senderAccountDetail: Account.Detail?,
        override var amount: BigInteger,
        val minimumBalance: Long,
        val senderAccountName: String,
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
                targetUser = targetUser,
                isMax = isMax,
                fee = calculatedFee ?: 0,
                assetInformation = assetInformation,
                note = note,
                xnote = xnote,
                senderAccountAddress = senderAccountAddress,
                senderAccountName = senderAccountName,
                senderAccountType = senderAccountType
            )
        }
    }

    data class AddAsset(
        override val senderAccountAddress: String,
        override val isSenderRekeyedToAnotherAccount: Boolean,
        override val senderAccountType: Account.Type?,
        override val senderAccountDetail: Account.Detail?,
        override val senderAuthAddress: String?,
        val assetInformation: AssetInformation
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation.AssetAddition(
                signedTransactionData = signedTransactionData,
                senderAccountAddress = senderAccountAddress,
                assetInformation = assetInformation
            )
        }
    }

    data class RemoveAsset(
        override val senderAccountAddress: String,
        override val senderAuthAddress: String?,
        override val senderAccountType: Account.Type?,
        override val senderAccountDetail: Account.Detail?,
        override val isSenderRekeyedToAnotherAccount: Boolean,
        val assetInformation: AssetInformation,
        val creatorPublicKey: String
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation.AssetRemoval(
                signedTransactionData = signedTransactionData,
                senderAccountAddress = senderAccountAddress,
                assetInformation = assetInformation
            )
        }
    }

    data class SendAndRemoveAsset(
        override val senderAccountAddress: String,
        override val senderAccountDetail: Account.Detail?,
        override val senderAuthAddress: String?,
        override val senderAccountType: Account.Type?,
        override val isSenderRekeyedToAnotherAccount: Boolean,
        override var amount: BigInteger,
        val senderAccountName: String,
        val assetInformation: AssetInformation,
        val note: String? = null,
        val targetUser: TargetUser,
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.Send(
                signedTransactionData = signedTransactionData,
                amount = amount,
                targetUser = targetUser,
                isMax = false,
                fee = calculatedFee ?: 0,
                assetInformation = assetInformation,
                note = note,
                senderAccountAddress = senderAccountAddress,
                senderAccountName = senderAccountName,
                senderAccountType = senderAccountType
            )
        }
    }

    data class Rekey(
        override val senderAccountAddress: String,
        override val isSenderRekeyedToAnotherAccount: Boolean,
        override val senderAccountType: Account.Type?,
        override val senderAccountDetail: Account.Detail?,
        override val senderAuthAddress: String?,
        val senderAccountAuthTypeAndDetail: Account.Detail?,
        val senderAccountName: String,
        val rekeyAdminAddress: String,
        val ledgerDetail: Account.Detail.Ledger,
    ) : TransactionData() {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.RekeyOperation(
                signedTransactionData = signedTransactionData,
                accountAddress = senderAccountAddress,
                accountDetail = senderAccountDetail,
                rekeyedAccountDetail = senderAccountAuthTypeAndDetail,
                rekeyAdminAddress = rekeyAdminAddress,
                ledgerDetail = ledgerDetail,
                accountName = senderAccountName
            )
        }
    }
}
