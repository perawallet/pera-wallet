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

package com.algorand.android.mapper

import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.SignTxnOptions
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.TransactionType.APP_TRANSACTION
import com.algorand.android.models.TransactionType.ASSET_CONFIGURATION
import com.algorand.android.models.TransactionType.ASSET_TRANSACTION
import com.algorand.android.models.TransactionType.PAY_TRANSACTION
import com.algorand.android.utils.walletconnect.getTransactionRequest
import com.google.gson.Gson
import javax.inject.Inject

class WalletConnectTransactionMapper @Inject constructor(
    private val paymentTransactionMapper: PaymentTransactionMapper,
    private val appCallTransactionMapper: AppCallTransactionMapper,
    private val assetTransferTransactionMapper: AssetTransferTransactionMapper,
    private val assetConfigurationTransactionMapper: AssetConfigurationTransactionMapper,
    private val gson: Gson
) {

    fun parseTransactionPayload(payload: List<*>): List<WCAlgoTransactionRequest>? {
        return try {
            (payload.first() as List<*>).map { rawTransactionRequest ->
                gson.fromJson(gson.toJson(rawTransactionRequest), WCAlgoTransactionRequest::class.java)
            }
        } catch (exception: Exception) {
            null
        }
    }

    fun parseSignTxnOptions(payload: List<*>): SignTxnOptions? {
        return try {
            val rawSignTxnOptions = (payload.getOrNull(TRANSACTION_SIGN_OPTIONS_INDEX) as? String)
            gson.fromJson(gson.toJson(rawSignTxnOptions), SignTxnOptions::class.java)
        } catch (exception: Exception) {
            null
        }
    }

    fun createWalletConnectTransaction(
        peerMeta: WalletConnectPeerMeta,
        rawTxn: WCAlgoTransactionRequest
    ): BaseWalletConnectTransaction? {
        val transactionRequest = rawTxn.getTransactionRequest(gson)
        return when (transactionRequest.transactionType) {
            PAY_TRANSACTION -> {
                paymentTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            APP_TRANSACTION -> {
                appCallTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            ASSET_TRANSACTION -> {
                assetTransferTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            ASSET_CONFIGURATION -> {
                assetConfigurationTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            else -> null
        }
    }

    companion object {
        private const val TRANSACTION_SIGN_OPTIONS_INDEX = 2
    }
}
