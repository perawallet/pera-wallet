/*
 * Copyright 2019 Algorand, Inc.
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

import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import java.math.BigInteger.ZERO
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class AssetTransferTransactionMapper @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val errorProvider: WalletConnectTransactionErrorProvider
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseWalletConnectTransaction? {
        return with(transactionRequest) {
            when {
                !rekeyAddress.isNullOrBlank() && !assetCloseToAddress.isNullOrBlank() -> {
                    createAssetTransferTransactionWithRekeyAndClose(peerMeta, transactionRequest, rawTxn)
                }
                assetCloseToAddress != null -> {
                    createAssetTransferTransactionWithClose(peerMeta, transactionRequest, rawTxn)
                }
                (assetAmount == null || assetAmount == ZERO) && senderAddress == assetReceiverAddress -> {
                    createAssetOptInTransaction(peerMeta, transactionRequest, rawTxn)
                }
                rekeyAddress != null -> {
                    createAssetTransferTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
                }
                else -> {
                    createAssetTransferTransaction(peerMeta, transactionRequest, rawTxn)
                }
            }
        }
    }

    private fun createAssetTransferTransactionWithClose(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAssetTransferTransaction.AssetTransferTransactionWithClose? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            BaseAssetTransferTransaction.AssetTransferTransactionWithClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId ?: return null,
                peerMeta = peerMeta,
                assetCloseToAddress = createWalletConnectAddress(assetCloseToAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = assetAmount ?: ZERO,
                accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress.decodedAddress),
                groupId = groupId
            )
        }
    }

    private fun createAssetTransferTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAssetTransferTransaction.AssetTransferTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            BaseAssetTransferTransaction.AssetTransferTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId ?: return null,
                peerMeta = peerMeta,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = assetAmount ?: ZERO,
                accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress.decodedAddress),
                groupId = groupId
            )
        }
    }

    private fun createAssetTransferTransactionWithRekeyAndClose(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAssetTransferTransaction.AssetTransferTransactionWithRekeyAndClose? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            BaseAssetTransferTransaction.AssetTransferTransactionWithRekeyAndClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId ?: return null,
                peerMeta = peerMeta,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = assetAmount ?: ZERO,
                accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress.decodedAddress),
                closeAddress = createWalletConnectAddress(assetCloseToAddress) ?: return null,
                groupId = groupId
            )
        }
    }

    private fun createAssetTransferTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAssetTransferTransaction.AssetTransferTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            BaseAssetTransferTransaction.AssetTransferTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId ?: return null,
                peerMeta = peerMeta,
                assetAmount = assetAmount ?: ZERO,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress.decodedAddress),
                groupId = groupId
            )
        }
    }

    private fun createAssetOptInTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAssetTransferTransaction.AssetOptInTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            BaseAssetTransferTransaction.AssetOptInTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId ?: return null,
                peerMeta = peerMeta,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress.decodedAddress),
                groupId = groupId
            )
        }
    }
}
