/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models.builder

import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.utils.MIN_FEE
import javax.inject.Inject

class BaseAppCallTransactionDetailUiBuilder @Inject constructor() :
    WalletConnectTransactionDetailBuilder<BaseAppCallTransaction> {

    override fun buildTransactionRequestSenderInfo(txn: BaseAppCallTransaction): TransactionRequestSenderInfo {
        return when (txn) {
            is BaseAppCallTransaction.AppCallCreationTransaction -> buildAppCallCreationSenderInfo(txn)
            else -> buildGeneralSenderInfo(txn)
        }
    }

    override fun buildTransactionRequestAmountInfo(txn: BaseAppCallTransaction): TransactionRequestAmountInfo {
        return with(txn) { TransactionRequestAmountInfo(fee = fee, shouldShowFeeWarning = fee > MIN_FEE) }
    }

    override fun buildTransactionRequestNoteInfo(txn: BaseAppCallTransaction): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note)
        }
    }

    override fun buildTransactionRequestExtrasInfo(txn: BaseAppCallTransaction): TransactionRequestExtrasInfo {
        return with(txn) { TransactionRequestExtrasInfo(rawTransaction = rawTransactionPayload, appId = appId) }
    }

    private fun buildAppCallCreationSenderInfo(
        txn: BaseAppCallTransaction.AppCallCreationTransaction
    ): TransactionRequestSenderInfo {
        return with(txn) {
            TransactionRequestSenderInfo(
                senderDisplayedAddress = senderAddress.decodedAddress,
                rekeyToAccountAddress = getRekeyToAccountAddress()?.decodedAddress,
                appId = appId,
                onCompletion = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete.appOnCompleteNo),
                approvalHash = approvalHash,
                clearStateHash = stateHash,
                appGlobalScheme = appGlobalSchema,
                appLocalScheme = appLocalSchema,
                appExtraPages = appExtraPages
            )
        }
    }

    private fun buildGeneralSenderInfo(txn: BaseAppCallTransaction): TransactionRequestSenderInfo {
        return with(txn) {
            TransactionRequestSenderInfo(
                senderDisplayedAddress = senderAddress.decodedAddress,
                rekeyToAccountAddress = getRekeyToAccountAddress()?.decodedAddress,
                appId = appId,
                onCompletion = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete.appOnCompleteNo),
                approvalHash = approvalHash,
                clearStateHash = stateHash,
                warningCount = warningCount
            )
        }
    }
}
