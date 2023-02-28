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

import com.algorand.android.models.BaseAccountAssetData
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
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.extensions.mapNotNull
import com.algorand.android.utils.multiplyOrZero
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import java.math.BigInteger
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class BaseAssetDeletionTransactionMapper @Inject constructor(
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val safeAmount = amount ?: BigInteger.ZERO
            if (assetIdBeingConfigured == null) return null
            val ownedAsset = accountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                    assetId = assetIdBeingConfigured,
                    publicKey = accountDetail.account.address
                )
            }
            val assetInformation = createWalletConnectAssetInformation(ownedAsset, safeAmount)
            val signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetDeletionTransaction.AssetDeletionTransaction(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = accountData?.accountInformation?.rekeyAdminAddress,
                fromAccount = WalletConnectAccount.create(accountData?.account),
                assetInformation = assetInformation,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetDeletionTransactionWithCloseTo(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseTo? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val safeAmount = amount ?: BigInteger.ZERO
            if (assetIdBeingConfigured == null) return null
            val ownedAsset = accountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                    assetId = assetIdBeingConfigured,
                    publicKey = accountDetail.account.address
                )
            }
            val assetInformation = createWalletConnectAssetInformation(ownedAsset, safeAmount)
            val signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseTo(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = accountData?.accountInformation?.rekeyAdminAddress,
                fromAccount = WalletConnectAccount.create(accountData?.account),
                assetInformation = assetInformation,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                groupId = groupId,
                warningCount = 2.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetDeletionTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val safeAmount = amount ?: BigInteger.ZERO
            if (assetIdBeingConfigured == null) return null
            val ownedAsset = accountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                    assetId = assetIdBeingConfigured,
                    publicKey = accountDetail.account.address
                )
            }
            val assetInformation = createWalletConnectAssetInformation(ownedAsset, safeAmount)
            val signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = accountData?.accountInformation?.rekeyAdminAddress,
                fromAccount = WalletConnectAccount.create(accountData?.account),
                assetInformation = assetInformation,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                groupId = groupId,
                warningCount = 2.takeIf { isLocalAccountSigner }
            )
        }
    }

    @SuppressWarnings("MagicNumber")
    private fun createAssetDeletionTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseToAndRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val safeAmount = amount ?: BigInteger.ZERO
            if (assetIdBeingConfigured == null) return null
            val ownedAsset = accountData.mapNotNull { accountDetail ->
                getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                    assetId = assetIdBeingConfigured,
                    publicKey = accountDetail.account.address
                )
            }
            val assetInformation = createWalletConnectAssetInformation(ownedAsset, safeAmount)
            val signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetDeletionTransaction.AssetDeletionTransactionWithCloseToAndRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = accountData?.accountInformation?.rekeyAdminAddress,
                fromAccount = WalletConnectAccount.create(accountData?.account),
                assetInformation = assetInformation,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                groupId = groupId,
                warningCount = 3.takeIf { isLocalAccountSigner }
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
