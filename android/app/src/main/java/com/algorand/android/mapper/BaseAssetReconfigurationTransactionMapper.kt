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
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction.Companion.isTransactionWithCloseTo
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction.Companion.isTransactionWithCloseToAndRekeyed
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction.Companion.isTransactionWithRekeyed
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

@SuppressWarnings("ReturnCount")
class BaseAssetReconfigurationTransactionMapper @Inject constructor(
    private val errorProvider: WalletConnectErrorProvider,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val walletConnectAssetInformationMapper: WalletConnectAssetInformationMapper,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetReconfigurationTransaction? {
        return when {
            isTransactionWithCloseToAndRekeyed(transactionRequest) -> {
                createAssetReconfigurationTransactionWithCloseToAndRekey(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithCloseTo(transactionRequest) -> {
                createAssetReconfigurationTransactionWithClose(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithRekeyed(transactionRequest) -> {
                createAssetReconfigurationTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
            }
            else -> {
                createAssetReconfigurationTransaction(peerMeta, transactionRequest, rawTxn)
            }
        }
    }

    private fun createAssetReconfigurationTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetReconfigurationTransaction.AssetReconfigurationTransaction? {
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
            val signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val assetInformation = createWalletConnectAssetInformation(ownedAsset, safeAmount)
            BaseAssetReconfigurationTransaction.AssetReconfigurationTransaction(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = assetInformation,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId
            )
        }
    }

    private fun createAssetReconfigurationTransactionWithClose(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithCloseTo? {
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
            BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithCloseTo(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = assetInformation,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetReconfigurationTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithRekey? {
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
            BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = assetInformation,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetReconfigurationTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithCloseToAndRekey? {
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
            BaseAssetReconfigurationTransaction.AssetReconfigurationTransactionWithCloseToAndRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                fromAccount = WalletConnectAccount.create(
                    account = accountData?.account,
                    accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                        accountAddress = accountData?.account?.address.orEmpty()
                    )
                ),
                assetInformation = assetInformation,
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                assetId = assetIdBeingConfigured,
                url = assetConfigParams?.url,
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 2.takeIf { isLocalAccountSigner }
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
