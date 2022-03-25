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

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.usecase.AlgoPriceUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.toAlgoDisplayValue
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

// TODO: 19.01.2022 Mappers shouldn't inject use case
@SuppressWarnings("ReturnCount")
class PaymentTransactionMapper @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val amount = amount ?: BigInteger.ZERO
            val assetInformation = accountCacheData?.assetsInformation?.firstOrNull {
                it.assetId == ALGORAND_ID
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(assetInformation, amount)

            BasePaymentTransaction.PaymentTransactionWithRekeyAndClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWalletConnectAddress ?: return null,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId
            )
        }
    }

    private fun createPaymentTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val amount = amount ?: BigInteger.ZERO
            val assetInformation = accountCacheData?.assetsInformation?.firstOrNull {
                it.assetId == ALGORAND_ID
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(assetInformation, amount)

            BasePaymentTransaction.PaymentTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWalletConnectAddress ?: return null,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId
            )
        }
    }

    private fun createPaymentTransactionWithClose(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransactionWithClose? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val amount = amount ?: BigInteger.ZERO
            val assetInformation = accountCacheData?.assetsInformation?.firstOrNull {
                it.assetId == ALGORAND_ID
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(assetInformation, amount)

            BasePaymentTransaction.PaymentTransactionWithClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWalletConnectAddress ?: return null,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId
            )
        }
    }

    private fun createPaymentTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTransaction: WCAlgoTransactionRequest
    ): BasePaymentTransaction.PaymentTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val amount = amount ?: BigInteger.ZERO
            val assetInformation = accountCacheData?.assetsInformation?.firstOrNull {
                it.assetId == ALGORAND_ID
            }
            val walletConnectAssetInformation = createWalletConnectAssetInformation(assetInformation, amount)

            BasePaymentTransaction.PaymentTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                amount = amount,
                senderAddress = senderWalletConnectAddress ?: return null,
                receiverAddress = createWalletConnectAddress(receiverAddress) ?: return null,
                peerMeta = peerMeta,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = walletConnectAssetInformation,
                groupId = groupId
            )
        }
    }

    private fun createWalletConnectAssetInformation(
        assetInformation: AssetInformation?,
        amount: BigInteger
    ): WalletConnectAssetInformation? {

        val algoPrice = algoPriceUseCase.getAlgoToSelectedCurrencyConversionRate()
            ?: BigDecimal.ZERO
        val currencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrCurrencyName()

        return walletConnectAssetInformationMapper.algorandMapToWalletConnectAssetInformation(
            assetInformation,
            amount.toAlgoDisplayValue().multiply(algoPrice),
            currencySymbol
        )
    }
}
