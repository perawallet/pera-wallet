/*
 * Copyright 2019 Algorand, Inc.
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

package com.algorand.android.ui.wctransactiondetail

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAmountInfo
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.models.WalletConnectSenderInfo
import com.algorand.android.network.AlgodInterceptor

class WalletConnectAppCallTransactionViewModel @ViewModelInject constructor(
    private val indexerInterceptor: AlgodInterceptor
) : BaseWalletConnectTransactionViewModel() {

    fun getExtras(transaction: BaseAppCallTransaction) {
        extrasLiveData.value = WalletConnectExtras(
            rawTransaction = transaction.rawTransactionPayload,
            note = transaction.note,
            assetId = transaction.appId,
            networkSlug = indexerInterceptor.currentActiveNode?.networkSlug
        )
    }

    fun getAmountInfo(transaction: BaseAppCallTransaction) {
        val amountInfo = WalletConnectAmountInfo(transaction.walletConnectTransactionParams.fee)
        amountInfoLiveData.value = amountInfo
    }

    fun getSenderInfo(transaction: BaseAppCallTransaction) {
        with(transaction) {
            val decodedAddress = senderAddress.decodedAddress ?: return
            val appCallCreationTransaction = transaction as? BaseAppCallTransaction.AppCallCreationTransaction
            val senderInfo = WalletConnectSenderInfo(
                senderDisplayedAddress = BaseWalletConnectDisplayedAddress.create(decodedAddress, account),
                senderTypeImageResId = getAccountImageResource(),
                dappName = peerMeta.name,
                rekeyToAccountAddress = formattedRekeyToAccountAddress,
                applicationId = appId,
                onComplete = appOnComplete,
                appGlobalSchema = appCallCreationTransaction?.appGlobalSchema,
                appLocalSchema = appCallCreationTransaction?.appLocalSchema,
                appExtraPages = appCallCreationTransaction?.appExtraPages,
                approvalHash = approvalHash,
                clearStateHash = stateHash
            )
            senderInfoLiveData.value = senderInfo
        }
    }
}
