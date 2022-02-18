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

package com.algorand.android.mapper

import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction.Companion.isTransactionWithCloseTo
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction.Companion.isTransactionWithCloseToAndRekeyed
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction.Companion.isTransactionWithRekeyed
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class BaseAssetDeletionTransactionMapper @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val errorProvider: WalletConnectTransactionErrorProvider
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction? {
        return when {
            isTransactionWithCloseToAndRekeyed(transactionRequest) -> {
                createAssetDeletionTransactionWithCloseToAndRekey(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithCloseTo(transactionRequest) -> {
                createAssetDeletionTransactionWithCloseTo(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithRekeyed(transactionRequest) -> {
                createAssetDeletionTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
            }
            else -> {
                createAssetDeletionTransaction(peerMeta, transactionRequest, rawTxn)
            }
        }
    }

    private fun createAssetDeletionTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetDeletionTransaction.AssetDeletionTransaction(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = WalletConnectAssetInformation.create(
                    accountCacheData?.assetsInformation?.find { it.assetId == assetIdBeingConfigured }
                ),
                assetId = assetIdBeingConfigured ?: return null,
                url = assetConfigParams?.url,
                groupId = groupId
            )
        }
    }

    private fun createAssetDeletionTransactionWithCloseTo(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseTo? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseTo(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = WalletConnectAssetInformation.create(
                    accountCacheData?.assetsInformation?.find { it.assetId == assetIdBeingConfigured }
                ),
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                assetId = assetIdBeingConfigured ?: return null,
                url = assetConfigParams?.url,
                groupId = groupId
            )
        }
    }

    private fun createAssetDeletionTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = WalletConnectAssetInformation.create(
                    accountCacheData?.assetsInformation?.find { it.assetId == assetIdBeingConfigured }
                ),
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured ?: return null,
                url = assetConfigParams?.url,
                groupId = groupId
            )
        }
    }

    private fun createAssetDeletionTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseToAndRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseToAndRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = WalletConnectAssetInformation.create(
                    accountCacheData?.assetsInformation?.find { it.assetId == assetIdBeingConfigured }
                ),
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured ?: return null,
                url = assetConfigParams?.url,
                groupId = groupId
            )
        }
    }
}
