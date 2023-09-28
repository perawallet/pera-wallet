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

import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.generateAddressFromProgram
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class AppCallTransactionMapper @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val errorProvider: WalletConnectErrorProvider,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAppCallTransaction.AppCallTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress,
                appArgs = appArgs,
                peerMeta = peerMeta,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                appId = appId ?: return null,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId,
                warningCount = if (isLocalAccountSigner) 1 else null
            )
        }
    }

    private fun createAppCallTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BaseAppCallTransaction.AppCallTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider)
            BaseAppCallTransaction.AppCallTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId ?: return null,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider)
            BaseAppCallTransaction.AppCallCreationTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider)
            BaseAppCallTransaction.AppOptInTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWalletConnectAddress,
                appArgs = appArgs,
                peerMeta = peerMeta,
                appId = appId ?: return null,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                appOnComplete = BaseAppCallTransaction.AppOnComplete.getByAppNoOrDefault(appOnComplete),
                approvalHash = generateAddressFromProgram(approvalHash),
                stateHash = generateAddressFromProgram(stateHash),
                groupId = groupId
            )
        }
    }
}
