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
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class SignedTransactionDetail : Parcelable {

    abstract val signedTransactionData: ByteArray

    @Parcelize
    data class Send(
        override val signedTransactionData: ByteArray,
        val amount: BigInteger,
        val accountCacheData: AccountCacheData,
        val targetUser: TargetUser,
        val isMax: Boolean,
        var fee: Long,
        val assetInformation: AssetInformation,
        val note: String? = null
    ) : SignedTransactionDetail()

    sealed class AssetOperation : SignedTransactionDetail() {

        abstract val accountCacheData: AccountCacheData
        abstract val assetInformation: AssetInformation

        @Parcelize
        data class AssetAddition(
            override val signedTransactionData: ByteArray,
            override val accountCacheData: AccountCacheData,
            override val assetInformation: AssetInformation
        ) : AssetOperation()

        @Parcelize
        data class AssetRemoval(
            override val signedTransactionData: ByteArray,
            override val accountCacheData: AccountCacheData,
            override val assetInformation: AssetInformation
        ) : AssetOperation()
    }

    @Parcelize
    data class RekeyOperation(
        override val signedTransactionData: ByteArray,
        val accountCacheData: AccountCacheData,
        val rekeyAdminAddress: String,
        val ledgerDetail: Account.Detail.Ledger
    ) : SignedTransactionDetail()

    @Parcelize
    data class Group(
        override val signedTransactionData: ByteArray,
        val transactions: List<SignedTransactionDetail>?
    ) : SignedTransactionDetail()
}
