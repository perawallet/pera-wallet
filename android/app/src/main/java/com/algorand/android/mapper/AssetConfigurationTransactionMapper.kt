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

import com.algorand.android.models.BaseAssetConfigurationTransaction.Companion.isAssetCreationTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.Companion.isAssetDeletion
import com.algorand.android.models.BaseAssetConfigurationTransaction.Companion.isAssetReconfigurationTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectTransactionRequest
import javax.inject.Inject

class AssetConfigurationTransactionMapper @Inject constructor(
    private val baseAssetCreationTransactionMapper: BaseAssetCreationTransactionMapper,
    private val baseAssetDeletionTransactionMapper: BaseAssetDeletionTransactionMapper,
    private val baseAssetReconfigurationTransactionMapper: BaseAssetReconfigurationTransactionMapper
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseWalletConnectTransaction? {
        return when {
            isAssetCreationTransaction(transactionRequest) -> {
                baseAssetCreationTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            isAssetReconfigurationTransaction(transactionRequest) -> {
                baseAssetReconfigurationTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            isAssetDeletion(transactionRequest) -> {
                baseAssetDeletionTransactionMapper.createTransaction(peerMeta, transactionRequest, rawTxn)
            }
            else -> null
        }
    }
}
