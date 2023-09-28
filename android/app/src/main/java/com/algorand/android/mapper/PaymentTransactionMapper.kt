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

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.extensions.mapNotNull
import com.algorand.android.utils.multiplyOrZero
import java.math.BigInteger
import javax.inject.Inject

// TODO: 19.01.2022 Mappers shouldn't inject use case
@SuppressWarnings("ReturnCount")
class PaymentTransactionMapper @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val errorProvider: WalletConnectErrorProvider,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseWalletConnectTransaction? {
        return with(transactionRequest) {
            when {
                !rekeyAddress.isNullOrBlank() && !closeToAddress.isNullOrBlank() -> {
                    createPaymentTransactionWithCloseToAndRekey(peerMeta, transactionRequest, rawTxn)
                }
                !rekeyAddress.isNullOrBlank() -> {
                    createPaymentTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
                }
                !closeToAddress.isNullOrBlank() -> {
                    createPaymentTransactionWithClose(peerMeta, transactionRequest, rawTxn)
                }
                else -> createPaymentTransaction(peerMeta, transactionRequest, rawTxn)
            }
        }
    }

    private fun createPaymentTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransactionWithRekeyAndClose? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(senderAddress) ?: return null
            val senderAccountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val amount = amount ?: BigInteger.ZERO
            val ownedAsset = senderAccountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(ALGO_ID, accountDetail.account.address)
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(ownedAsset, amount)
            val signer = WalletConnectSigner.create(rawTransaction, senderWCAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BasePaymentTransaction.PaymentTransactionWithRekeyAndClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWCAddress,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = signer,
                authAddress = getAuthAddress(senderAccountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = senderAccountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = senderAccountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId,
                warningCount = 2.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createPaymentTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(senderAddress) ?: return null
            val senderAccountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val amount = amount ?: BigInteger.ZERO
            val ownedAsset = senderAccountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(ALGO_ID, accountDetail.account.address)
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(ownedAsset, amount)
            val signer = WalletConnectSigner.create(rawTransaction, senderWCAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BasePaymentTransaction.PaymentTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWCAddress,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = signer,
                authAddress = getAuthAddress(senderAccountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = senderAccountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = senderAccountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createPaymentTransactionWithClose(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransactionWithClose? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(senderAddress) ?: return null
            val senderAccountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val amount = amount ?: BigInteger.ZERO
            val ownedAsset = senderAccountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(ALGO_ID, accountDetail.account.address)
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(ownedAsset, amount)
            val signer = WalletConnectSigner.create(rawTransaction, senderWCAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BasePaymentTransaction.PaymentTransactionWithClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWCAddress,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                signer = signer,
                authAddress = getAuthAddress(senderAccountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = senderAccountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = senderAccountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createPaymentTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransaction? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(senderAddress) ?: return null
            val senderAccountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val receiverWCAddress = createWalletConnectAddress(receiverAddress)
            val receiverAccountData = receiverWCAddress?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
            }
            val amount = amount ?: BigInteger.ZERO
            val ownedAsset = senderAccountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(ALGO_ID, accountDetail.account.address)
            }
            val signer = WalletConnectSigner.create(rawTransaction, senderWCAddress, errorProvider)
            val walletConnectAssetInformation = createWalletConnectAssetInformation(ownedAsset, amount)
            BasePaymentTransaction.PaymentTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWCAddress,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                signer = signer,
                authAddress = getAuthAddress(senderAccountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = senderAccountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = senderAccountData?.account?.address.orEmpty()
                    )
                ),
                toAccount = WalletConnectAccount.create(
                    account = receiverAccountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = receiverAccountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId
            )
        }
    }

    private fun createWalletConnectAssetInformation(
        ownedAsset: BaseAccountAssetData.BaseOwnedAssetData?,
        amount: BigInteger
    ): WalletConnectAssetInformation? {
        if (ownedAsset == null) return null
        val safeAmount = amount.toBigDecimal().movePointLeft(ownedAsset.decimals).multiplyOrZero(ownedAsset.usdValue)
        return walletConnectAssetInformationMapper.mapToWalletConnectAssetInformation(ownedAsset, safeAmount)
    }
}
