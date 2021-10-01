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
import com.algorand.android.models.AssetParams
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BaseWalletConnectDisplayedAddress
import com.algorand.android.models.WalletConnectAmountInfo
import com.algorand.android.models.WalletConnectExtras
import com.algorand.android.models.WalletConnectTransactionInfo
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.AccountCacheManager

class WalletConnectAssetTransactionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val indexerInterceptor: AlgodInterceptor
) : BaseWalletConnectTransactionViewModel() {

    fun getExtras(transaction: BaseAssetTransferTransaction) {
        when (transaction) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> {
                val assetParams = getAssetParams(transaction.assetId) ?: return
                extrasLiveData.value = WalletConnectExtras(
                    rawTransaction = transaction.rawTransactionPayload,
                    note = transaction.note,
                    assetUrl = assetParams.url,
                    assetMetadata = assetParams.appendAssetId(transaction.assetId),
                    assetId = transaction.assetId,
                    networkSlug = indexerInterceptor.currentActiveNode?.networkSlug
                )
            }
            else -> {
                extrasLiveData.value = WalletConnectExtras(
                    rawTransaction = transaction.rawTransactionPayload,
                    note = transaction.note
                )
            }
        }
    }

    fun getAmountInfo(transaction: BaseAssetTransferTransaction) {
        when (transaction) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> {
                val amountInfo = WalletConnectAmountInfo(transaction.walletConnectTransactionParams.fee)
                amountInfoLiveData.value = amountInfo
            }
            else -> {
                val amountInfo = with(transaction) {
                    WalletConnectAmountInfo(
                        fee = walletConnectTransactionParams.fee,
                        amount = transactionAmount,
                        decimal = assetDecimal,
                        toAccountAddress = assetReceiverAddress.decodedAddress,
                    )
                }
                amountInfoLiveData.value = amountInfo
            }
        }
    }

    fun getTransactionInfo(transaction: BaseAssetTransferTransaction) {
        with(transaction) {
            val decodedSenderAddress = senderAddress.decodedAddress ?: return
            val accountCache = accountCacheManager.getCacheData(decodedSenderAddress)
            val transactionInfo = WalletConnectTransactionInfo(
                BaseWalletConnectDisplayedAddress.create(decodedSenderAddress, accountCacheData),
                peerMeta.name,
                accountCache?.getImageResource(),
                accountCacheManager.getAssetInformation(decodedSenderAddress, assetId)?.amount,
                assetParams?.convertToAssetInformation(assetId),
                formattedRekeyToAccountAddress,
                formattedCloseToAccountAddress,
                assetDecimal
            )
            transactionInfoLiveData.value = transactionInfo
        }
    }

    private fun getAssetParams(assetId: Long): AssetParams? {
        val assetParams = accountCacheManager.getAssetDescription(assetId)
        if (assetParams != null) {
            return assetParams
        }
        return null
    }
}
