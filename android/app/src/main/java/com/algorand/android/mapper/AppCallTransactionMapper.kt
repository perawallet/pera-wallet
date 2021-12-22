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

import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.generateAddressFromProgram
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class AppCallTransactionMapper @Inject constructor(
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
                appId == null || appId == 0L -> {
                    createAppCallCreationTransaction(peerMeta, transactionRequest, rawTxn)
                }
                rekeyAddress != null -> {
                    createAppCallTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
                }
                appOnComplete == null -> {
                    createAppCallTransaction(peerMeta, transactionRequest, rawTxn)
                }
                BaseAppCallTransaction.AppOnComplete.isSupportedOnComplete(appOnComplete) -> {
                    createAppOptInTransaction(peerMeta, transactionRequest, rawTxn)
                }
                else -> null
            }
        }
    }

    private fun createAppCallTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAppCallTransaction.AppCallTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAppCallTransaction.AppCallTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress ?: return null,
                appArgs = appArgs,
                peerMeta = peerMeta,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                appId = appId ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId
            )
        }
    }

    private fun createAppCallTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAppCallTransaction.AppCallTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAppCallTransaction.AppCallTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress ?: return null,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId
            )
        }
    }

    private fun createAppCallCreationTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAppCallTransaction.AppCallCreationTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAppCallTransaction.AppCallCreationTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress ?: return null,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                appGlobalSchema = appGlobalSchema,
                appLocalSchema = appLocalSchema,
                appExtraPages = appExtraPages ?: 0,
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId
            )
        }
    }

    private fun createAppOptInTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAppCallTransaction.AppOptInTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAppCallTransaction.AppOptInTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress ?: return null,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId
            )
        }
    }
}
