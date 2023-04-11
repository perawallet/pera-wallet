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

package com.algorand.android.ui.wcrawtransaction

import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.DecodedWalletConnectTransactionRequest
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectRawTransaction
import com.algorand.android.models.WalletConnectTransactionAssetDetail
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.decodeBase64DecodedMsgPackToJsonString
import com.algorand.android.utils.getFormattedJsonArrayString
import com.google.gson.Gson
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class WalletConnectRawMessageViewModel @Inject constructor(
    private val gson: Gson
) : BaseViewModel() {

    fun getFormattedTransactionJson(txnRequest: WCAlgoTransactionRequest): String {
        val transaction = gson.fromJson(
            decodeBase64DecodedMsgPackToJsonString(txnRequest.transactionMsgPack),
            WalletConnectTransactionRequest::class.java
        )
        val decodedTransaction = DecodedWalletConnectTransactionRequest.create(transaction)
        val signerAccountList = txnRequest.signers
        val rawTxn = WalletConnectRawTransaction(decodedTransaction, signerAccountList)
        return getFormattedJsonArrayString(gson.toJson(rawTxn))
    }

    fun formatAssetMetadata(walletConnectTransactionAssetDetail: WalletConnectTransactionAssetDetail?): String {
        val jsonObject = gson.toJson(walletConnectTransactionAssetDetail)
        return getFormattedJsonArrayString(jsonObject)
    }
}
