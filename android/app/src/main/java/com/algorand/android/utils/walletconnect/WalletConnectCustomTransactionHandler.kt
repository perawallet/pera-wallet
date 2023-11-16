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

import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WalletConnectRequest.WalletConnectTransaction
import com.algorand.android.models.WalletConnectTransactionSigner.Rekeyed
import com.algorand.android.models.WalletConnectTransactionSigner.Sender
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.ui.mapper.WalletConnectTransactionMapper
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.groupWalletConnectTransactions
import com.algorand.android.utils.walletconnect.WalletConnectRequestResult.Error
import com.algorand.android.utils.walletconnect.WalletConnectRequestResult.Success
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope

class WalletConnectCustomTransactionHandler @Inject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val walletConnectTransactionMapper: WalletConnectTransactionMapper,
    private val errorProvider: WalletConnectErrorProvider,
    private val accountCacheManager: AccountCacheManager,
    private val walletConnectCustomTransactionAssetDetailHandler: WalletConnectCustomTransactionAssetDetailHandler
) {

    /*
    * Transaction validation rules
    * -> Parsed transcation payload must not be null (List<WCAlgoTransactionRequest>)
    * -> Transaction list size must be 1 to MAX_TRANSACTION_COUNT (List<WCAlgoTransactionRequest>)
    * -> Convert List<WCAlgoTransactionRequest> to List<BaseWalletConnectTransaction>
    * -> After this conversion check list sizes if they are matching
    * -> Check if nodes are matching
    * -> If it's needed set asset detail
    * -> Check if any assset tranfer transaction doesn't contain asset detail info
    * -> Create grouped wc transactions
    * -> This group can't be empty
    * -> Check if all wc ids and auth account addresses are valid
    * -> Check if all the signers are valid
    * -> hasAllAtomicAtLeastOneTxnNeedsToBeSigned
    * -> doAppHaveAtLeastOneSignerAccountInTxn
    *
    *
    *
    * */
    @SuppressWarnings("ReturnCount", "LongMethod")
    suspend fun handleCustomTransaction(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        session: WalletConnect.SessionDetail,
        payloadList: List<*>,
        scope: CoroutineScope,
        onResult: suspend (WalletConnectRequestResult) -> Unit
    ) {
        try {
            val wcAlgoTxnRequestList = walletConnectTransactionMapper.parseTransactionPayload(payloadList)

            if (wcAlgoTxnRequestList == null) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getUnableToParseTransactionError()))
                return
            }

            if (wcAlgoTxnRequestList.size > MAX_TRANSACTION_COUNT) {
                val error = errorProvider.getMaxTransactionLimitError(MAX_TRANSACTION_COUNT)
                onResult(Error(sessionIdentifier, requestIdentifier, error))
                return
            }

            val walletConnectTxnList = wcAlgoTxnRequestList.mapNotNull {
                walletConnectTransactionMapper.createWalletConnectTransaction(session.peerMeta, it)
            }

            if (walletConnectTxnList.size != wcAlgoTxnRequestList.size) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getUnableToParseTransactionError()))
                return
            }

            if (!checkIfNodesMatchesAndSetTransactionLastRound(walletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getMismatchingNodesError()))
                return
            }

            setAssetParamsIfNeed(walletConnectTxnList, scope)

            if (hasInvalidAssetTransfer(walletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getInvalidAssetError()))
                return
            }

            val groupedWalletConnectTxnList = groupWalletConnectTransactions(walletConnectTxnList)

            if (groupedWalletConnectTxnList == null) {
                val error = errorProvider.getFailedGroupingTransactionsError()
                onResult(Error(sessionIdentifier, requestIdentifier, error))
                return
            }

            if (!areAllAddressPublicKeysValid(groupedWalletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getInvalidPublicKeyError()))
                return
            }

            if (hasValidSigner(walletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getMissingSignerError()))
                return
            }

            if (!hasAllAtomicAtLeastOneTxnNeedsToBeSigned(groupedWalletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getAtomicNoNeedToSignError()))
                return
            }

            if (!doAppHaveAtLeastOneSignerAccountInTxn(groupedWalletConnectTxnList)) {
                onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getMissingSignerError()))
                return
            }

            val transactionMessage = walletConnectTransactionMapper.parseSignTxnOptions(payloadList)?.message
            val requestId = requestIdentifier.getIdentifier()
            val version = sessionIdentifier.versionIdentifier
            val walletConnectSession = walletConnectTransactionMapper.mapToWalletConnectSession(session)
            val result = WalletConnectTransaction(
                requestId = requestId,
                transactionList = groupedWalletConnectTxnList,
                session = walletConnectSession,
                message = transactionMessage,
                versionIdentifier = version
            )
            onResult(Success(result))
        } catch (exception: Exception) {
            onResult(Error(sessionIdentifier, requestIdentifier, errorProvider.getUnableToParseTransactionError()))
        } finally {
            walletConnectCustomTransactionAssetDetailHandler.clearAssetCacheMap()
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
                it.walletConnectTransactionAssetDetail == null
            }
        }
    }

    private suspend fun setAssetParamsIfNeed(
        walletConnectTxnList: List<BaseWalletConnectTransaction>,
        scope: CoroutineScope
    ) {
        val assetListToBeFetched = walletConnectTxnList.filterIsInstance<WalletConnectAssetDetail>()
        if (assetListToBeFetched.isEmpty()) return
        val assetIdListToBeFetched = assetListToBeFetched.map { it.assetId }
        val assetDetailMap = walletConnectCustomTransactionAssetDetailHandler.getAssetParamsDefinedWCTransactionList(
            assetIdList = assetIdListToBeFetched,
            scope = scope
        )
        assetListToBeFetched.forEach {
            it.walletConnectTransactionAssetDetail = assetDetailMap[it.assetId]
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
                txn.signer is Sender || txn.signer is Rekeyed
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
        const val MAX_TRANSACTION_COUNT = 1000
    }
}
