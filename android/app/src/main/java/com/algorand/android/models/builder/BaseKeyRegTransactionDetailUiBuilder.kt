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

package com.algorand.android.models.builder

import com.algorand.android.models.BaseKeyRegTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.utils.MIN_FEE

abstract class BaseKeyRegTransactionDetailUiBuilder :
    WalletConnectTransactionDetailBuilder<BaseKeyRegTransaction> {

    override fun buildTransactionRequestSenderInfo(txn: BaseKeyRegTransaction): TransactionRequestSenderInfo? {
        return with(txn) {
            TransactionRequestSenderInfo(
                fromDisplayedAddress = getFromAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIconDrawablePreview = getFromAccountIconResource(),
                rekeyToAccountAddress = getRekeyToAccountAddress()?.decodedAddress,
                warningCount = warningCount
            )
        }
    }

    override fun buildTransactionRequestNoteInfo(txn: BaseKeyRegTransaction): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note)
        }
    }

    override fun buildTransactionRequestExtrasInfo(txn: BaseKeyRegTransaction): TransactionRequestExtrasInfo {
        return with(txn) { TransactionRequestExtrasInfo(rawTransaction = rawTransactionPayload) }
    }

    override fun buildTransactionRequestAmountInfo(txn: BaseKeyRegTransaction): TransactionRequestAmountInfo {
        return with(txn) { TransactionRequestAmountInfo(fee = fee, shouldShowFeeWarning = fee > MIN_FEE) }
    }
}
