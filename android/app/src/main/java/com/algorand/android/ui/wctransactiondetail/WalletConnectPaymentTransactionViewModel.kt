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
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAmountInfo
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.models.WalletConnectTransactionInfo
import java.math.BigInteger

class WalletConnectPaymentTransactionViewModel @ViewModelInject constructor() :
    BaseWalletConnectTransactionViewModel() {

    fun getExtras(transaction: BasePaymentTransaction) {
        extrasLiveData.value = WalletConnectExtras(
            rawTransaction = transaction.rawTransactionPayload,
            note = transaction.note
        )
    }

    fun getAmountInfo(transaction: BasePaymentTransaction) {
        with(transaction) {
            val amountInfo = WalletConnectAmountInfo(
                walletConnectTransactionParams.fee,
                transactionAmount,
                assetDecimal,
                receiverAddress.decodedAddress,
                isAlgorand = true
            )
            amountInfoLiveData.value = amountInfo
        }
    }

    fun getTransactionInfo(transaction: BasePaymentTransaction) {
        with(transaction) {
            val decodedSenderAddress = senderAddress.decodedAddress ?: return
            val accountBalance: BigInteger?
            val assetInformation = accountCacheData?.assetsInformation?.firstOrNull { it.assetId == ALGORAND_ID }.run {
                accountBalance = this?.amount
                this ?: AssetInformation.getAlgorandAsset()
            }
            val transactionInfo = WalletConnectTransactionInfo(
                BaseWalletConnectDisplayedAddress.create(decodedSenderAddress, accountCacheData),
                peerMeta.name,
                accountCacheData?.getImageResource(),
                accountBalance,
                assetInformation,
                formattedRekeyToAccountAddress,
                formattedCloseToAccountAddress,
                assetDecimal
            )
            transactionInfoLiveData.value = transactionInfo
        }
    }
}
