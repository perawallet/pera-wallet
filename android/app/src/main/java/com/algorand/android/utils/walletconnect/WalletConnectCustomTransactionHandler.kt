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

package com.algorand.android.utils.walletconnect

import com.algorand.android.mapper.WalletConnectTransactionMapper
import com.algorand.android.models.AssetParams
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.groupWalletConnectTransactions
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Error
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Success
import javax.inject.Inject

class WalletConnectCustomTransactionHandler @Inject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val walletConnectTransactionMapper: WalletConnectTransactionMapper,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val accountCacheManager: AccountCacheManager,
    private val assetRepository: AssetRepository
) {

    /**
     * Stores asset detail that wallet connect request contains
     * to fasten the process for requests that contains same asset
     */
    private val assetCacheMap = mutableMapOf<Long, AssetParams>()

    @SuppressWarnings("ReturnCount")
    suspend fun handleCustomTransaction(
        sessionId: Long,
        requestId: Long,
        session: WalletConnectSession,
        payloadList: List<*>,
        onResult: (WalletConnectTransactionResult) -> Unit
    ) {
        try {
            val wcAlgoTxnRequestList = walletConnectTransactionMapper.parseTransactionPayload(payloadList)

            if (wcAlgoTxnRequestList == null) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.unableToParse))
                return
            }

            if (wcAlgoTxnRequestList.size > MAX_TRANSACTION_COUNT) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.maxTransactionLimit))
                return
            }

            val walletConnectTxnList = wcAlgoTxnRequestList.mapNotNull {
                walletConnectTransactionMapper.createWalletConnectTransaction(session.peerMeta, it)
            }

            if (walletConnectTxnList.size != wcAlgoTxnRequestList.size) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.unableToParse))
                return
            }

            if (!checkIfNodesMatchesAndSetTransactionLastRound(walletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.unauthorized.mismatchingNodes))
                return
            }

            setAssetParamsIfNeed(walletConnectTxnList)

            if (hasInvalidAssetTransfer(walletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.invalidAsset))
                return
            }

            // TODO reject if there is an error
            val groupedWalletConnectTxnList = groupWalletConnectTransactions(walletConnectTxnList)

            if (!areAllAddressPublicKeysValid(groupedWalletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.invalidPublicKey))
                return
            }

            if (hasValidSigner(walletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.invalidSigner))
                return
            }

            if (!hasAllAtomicAtLeastOneTxnNeedsToBeSigned(groupedWalletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.invalidInput.atomicTxnNoNeedToBeSigned))
                return
            }

            if (!doAppHaveAtLeastOneSignerAccountInTxn(groupedWalletConnectTxnList)) {
                onResult(Error(sessionId, requestId, errorProvider.unauthorized.missingSigner))
                return
            }

            val transactionMessage = walletConnectTransactionMapper.parseSignTxnOptions(payloadList)?.message
            val result = WalletConnectTransaction(requestId, groupedWalletConnectTxnList, session, transactionMessage)
            onResult(Success(result))
            assetCacheMap.clear()
        } catch (exception: Exception) {
            onResult(Error(sessionId, requestId, errorProvider.invalidInput.unableToParse))
            assetCacheMap.clear()
        }
    }

    private fun hasValidSigner(walletConnectTxnList: List<BaseWalletConnectTransaction>): Boolean {
        return walletConnectTxnList.all {
            !it.signer.isValidSigner
        }
    }

    private suspend fun checkIfNodesMatchesAndSetTransactionLastRound(
        txnRequestList: List<BaseWalletConnectTransaction>
    ): Boolean {
        var isNodesMatches = false
        transactionsRepository.getTransactionParams().use(
            onSuccess = { txnParams ->
                isNodesMatches = txnRequestList.all { txn ->
                    with(txn) {
                        requestedBlockCurrentRound = txnParams.lastRound
                        with(walletConnectTransactionParams) {
                            genesisHash == txnParams.genesisHash && genesisId == txnParams.genesisId
                        }
                    }
                }
            },
            onFailed = { _, _ -> isNodesMatches = false }
        )
        return isNodesMatches
    }

    private fun hasInvalidAssetTransfer(walletConnectTxnList: List<BaseWalletConnectTransaction>): Boolean {
        val baseAssetTransferList = walletConnectTxnList.filterIsInstance<BaseAssetTransferTransaction>()
        return if (baseAssetTransferList.isEmpty()) {
            false
        } else {
            baseAssetTransferList.any {
                it.assetParams == null
            }
        }
    }

    private suspend fun setAssetParamsIfNeed(walletConnectTxnList: List<BaseWalletConnectTransaction>) {
        val assetListToBeFetched = walletConnectTxnList.filterIsInstance<WalletConnectAssetDetail>()
        if (assetListToBeFetched.isEmpty()) return
        assetListToBeFetched.forEach {
            getAssetParams(it)
        }
    }

    private suspend fun getAssetParams(assetTransaction: WalletConnectAssetDetail) {
        val cachedAsset = assetCacheMap.getOrDefault(assetTransaction.assetId, null)
        if (cachedAsset != null) {
            assetTransaction.assetParams = cachedAsset
        } else {
            assetRepository.getAssetDescription(assetTransaction.assetId).use(
                onSuccess = {
                    assetCacheMap[assetTransaction.assetId] = it.assetParams
                    assetTransaction.assetParams = it.assetParams
                },
                onFailed = { _, _ ->
                    // TODO Handle fail case
                }
            )
        }
    }

    private fun areAllAddressPublicKeysValid(groupedTxnList: List<List<BaseWalletConnectTransaction>>): Boolean {
        return groupedTxnList.all { txnList ->
            txnList.all { txn ->
                txn.getAllAddressPublicKeysTxnIncludes().all { wcAddress ->
                    wcAddress.isValid
                } && txn.isAuthAddressValid()
            }
        }
    }

    private fun hasAllAtomicAtLeastOneTxnNeedsToBeSigned(
        groupedTxnList: List<List<BaseWalletConnectTransaction>>
    ): Boolean {
        return groupedTxnList.all { txnList ->
            txnList.any { txn ->
                txn.signer is WalletConnectSigner.Sender || txn.signer is WalletConnectSigner.Rekeyed
            }
        }
    }

    private fun doAppHaveAtLeastOneSignerAccountInTxn(
        groupedTxnList: List<List<BaseWalletConnectTransaction>>
    ): Boolean {
        return groupedTxnList.all { txnList ->
            txnList.any { txn ->
                val signerPublicKey = txn.signer.address?.decodedAddress
                accountCacheManager.getCacheData(signerPublicKey) != null
            }
        }
    }

    companion object {
        const val MAX_TRANSACTION_COUNT = 64
    }
}
