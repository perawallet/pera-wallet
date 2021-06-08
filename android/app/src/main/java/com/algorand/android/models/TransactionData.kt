/*
 * Copyright 2019 Algorand, Inc.
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

sealed class TransactionData(
    val accountCacheData: AccountCacheData,
    var calculatedFee: Long? = null,
    var transactionByteArray: ByteArray? = null,
    var amount: Long = 0
) {
    abstract fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail

    class Send(
        accountCacheData: AccountCacheData,
        amount: Long,
        val assetInformation: AssetInformation,
        val note: String? = null,
        val targetUser: TargetUser,
        var isMax: Boolean = false,
        var projectedFee: Long = 0
    ) : TransactionData(accountCacheData, amount = amount) {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.Send(
                signedTransactionData,
                amount,
                accountCacheData,
                targetUser,
                isMax,
                calculatedFee ?: 0,
                assetInformation,
                note
            )
        }
    }

    class AddAsset(
        accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation
    ) : TransactionData(accountCacheData) {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation(signedTransactionData, accountCacheData, assetInformation)
        }
    }

    class RemoveAsset(
        accountCacheData: AccountCacheData,
        val assetInformation: AssetInformation,
        val creatorPublicKey: String
    ) : TransactionData(accountCacheData) {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.AssetOperation(signedTransactionData, accountCacheData, assetInformation)
        }
    }

    class Rekey(
        accountCacheData: AccountCacheData,
        val rekeyAdminAddress: String,
        val ledgerDetail: Account.Detail.Ledger,
    ) : TransactionData(accountCacheData) {
        override fun getSignedTransactionDetail(signedTransactionData: ByteArray): SignedTransactionDetail {
            return SignedTransactionDetail.RekeyOperation(
                signedTransactionData, accountCacheData, rekeyAdminAddress, ledgerDetail
            )
        }
    }
}
