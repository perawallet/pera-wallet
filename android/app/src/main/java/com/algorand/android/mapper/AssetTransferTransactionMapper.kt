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

import com.algorand.android.models.AccountDetail
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectAssetInformation
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AlgoPriceUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import java.math.BigInteger
import java.math.BigInteger.ZERO
import javax.inject.Inject

// TODO: 19.01.2022 Mappers shouldn't inject use case
@SuppressWarnings("ReturnCount")
class AssetTransferTransactionMapper @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper
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
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val assetId = assetId ?: return null
            val amount = assetAmount ?: ZERO
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(senderAddress ?: return null)?.data
            val assetInformation = createWalletConnectAssetInformation(assetId, accountDetail, amount)

            BaseAssetTransferTransaction.AssetTransferTransactionWithClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId,
                peerMeta = peerMeta,
                assetCloseToAddress = createWalletConnectAddress(assetCloseToAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = amount,
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = assetInformation,
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
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val assetId = assetId ?: return null
            val amount = assetAmount ?: ZERO
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(senderAddress ?: return null)?.data
            val assetInformation = createWalletConnectAssetInformation(assetId, accountDetail, amount)

            BaseAssetTransferTransaction.AssetTransferTransactionWithRekey(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId,
                peerMeta = peerMeta,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = amount,
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = assetInformation,
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
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val assetId = assetId ?: return null
            val amount = assetAmount ?: ZERO
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(senderAddress ?: return null)?.data
            val assetInformation = createWalletConnectAssetInformation(assetId, accountDetail, amount)

            BaseAssetTransferTransaction.AssetTransferTransactionWithRekeyAndClose(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId,
                peerMeta = peerMeta,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                assetAmount = amount,
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = assetInformation,
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
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val assetId = assetId ?: return null
            val amount = assetAmount ?: ZERO
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(senderAddress ?: return null)?.data
            val assetInformation = createWalletConnectAssetInformation(assetId, accountDetail, amount)

            BaseAssetTransferTransaction.AssetTransferTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId,
                peerMeta = peerMeta,
                assetAmount = amount,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = assetInformation,
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
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            val assetId = assetId ?: return null
            val amount = assetAmount ?: ZERO
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(senderAddress ?: return null)?.data
            val assetInformation = createWalletConnectAssetInformation(assetId, accountDetail, amount)

            BaseAssetTransferTransaction.AssetOptInTransaction(
                rawTransactionPayload = rawTransaction,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                assetReceiverAddress = createWalletConnectAddress(assetReceiverAddress) ?: return null,
                senderAddress = senderWalletConnectAddress ?: return null,
                assetId = assetId,
                peerMeta = peerMeta,
                signer = WalletConnectSigner.create(rawTransaction, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
                assetInformation = assetInformation,
                groupId = groupId
            )
        }
    }

    private fun createWalletConnectAssetInformation(
        assetId: Long,
        accountDetail: AccountDetail?,
        amount: BigInteger
    ): WalletConnectAssetInformation? {

        val assetQueryItem = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
        val assetHolding = accountDetail?.accountInformation?.assetHoldingList?.firstOrNull {
            it.assetId == assetId
        }
        val selectedCurrencyUsdConversionRate = algoPriceUseCase.getUsdToSelectedCurrencyConversionRate()
        val currencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrCurrencyName()
        return walletConnectAssetInformationMapper.otherAssetMapToWalletConnectAssetInformation(
            assetDetail = assetQueryItem,
            assetHolding = assetHolding,
            amount,
            selectedCurrencyUsdConversionRate,
            currencySymbol
        )
    }
}
