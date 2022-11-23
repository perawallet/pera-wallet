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
import com.algorand.android.ledger.operations.ExternalTransaction
import com.algorand.android.modules.algosdk.domain.model.RawTransaction
import com.algorand.android.utils.decodeBase64
import com.algorand.android.utils.isRekeyedToAnotherAccount
import kotlinx.parcelize.Parcelize

@Parcelize
data class UnsignedSwapSingleTransactionData(
    override val parentListIndex: Int,
    override val transactionListIndex: Int,
    val transactionMsgPack: String?,
    override val accountAddress: String,
    override val accountAuthAddress: String?,
    val decodedTransaction: RawTransaction?
) : BaseSwapSingleTransactionData, Parcelable, ExternalTransaction {

    override val isRekeyedToAnotherAccount: Boolean
        get() = isRekeyedToAnotherAccount(accountAuthAddress, accountAddress)

    override val transactionByteArray: ByteArray?
        get() = transactionMsgPack?.decodeBase64()
}
