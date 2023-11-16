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

import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetCreationTransaction.Companion.isTransactionWithCloseTo
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetCreationTransaction.Companion.isTransactionWithCloseToAndRekeyed
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetCreationTransaction.Companion.isTransactionWithRekeyed
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.models.WalletConnectTransactionSigner
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import com.algorand.android.utils.walletconnect.encodeBase64EncodedHexString
import java.math.BigInteger
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class BaseAssetCreationTransactionMapper @Inject constructor(
    private val errorProvider: WalletConnectErrorProvider,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction? {
        return when {
            isTransactionWithCloseToAndRekeyed(transactionRequest) -> {
                createAssetCreationTransactionWithCloseToAndRekey(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithCloseTo(transactionRequest) -> {
                createAssetCreationTransactionWithCloseTo(peerMeta, transactionRequest, rawTxn)
            }
            isTransactionWithRekeyed(transactionRequest) -> {
                createAssetCreationTransactionWithRekey(peerMeta, transactionRequest, rawTxn)
            }
            else -> {
                createAssetCreationTransaction(peerMeta, transactionRequest, rawTxn)
            }
        }
    }

    private fun createAssetCreationTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransaction? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            BaseAssetCreationTransaction.AssetCreationTransaction(
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
                totalAmount = assetConfigParams?.totalSupply ?: BigInteger.ZERO,
                decimals = assetConfigParams?.decimal ?: 0,
                isFrozen = assetConfigParams?.isFrozen ?: false,
                assetName = assetConfigParams?.name,
                unitName = assetConfigParams?.unitName,
                url = assetConfigParams?.url,
                metadataHash = encodeBase64EncodedHexString(assetConfigParams?.metadataHash),
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId
            )
        }
    }

    private fun createAssetCreationTransactionWithCloseTo(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransactionWithCloseTo? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetCreationTransaction.AssetCreationTransactionWithCloseTo(
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
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                totalAmount = assetConfigParams?.totalSupply ?: BigInteger.ZERO,
                decimals = assetConfigParams?.decimal ?: 0,
                isFrozen = assetConfigParams?.isFrozen ?: false,
                assetName = assetConfigParams?.name,
                unitName = assetConfigParams?.unitName,
                url = assetConfigParams?.url,
                metadataHash = encodeBase64EncodedHexString(assetConfigParams?.metadataHash),
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetCreationTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransactionWithCloseToAndRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetCreationTransaction.AssetCreationTransactionWithCloseToAndRekey(
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
                closeToAddress = createWalletConnectAddress(closeToAddress) ?: return null,
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                totalAmount = assetConfigParams?.totalSupply ?: BigInteger.ZERO,
                decimals = assetConfigParams?.decimal ?: 0,
                isFrozen = assetConfigParams?.isFrozen ?: false,
                assetName = assetConfigParams?.name,
                unitName = assetConfigParams?.unitName,
                url = assetConfigParams?.url,
                metadataHash = encodeBase64EncodedHexString(assetConfigParams?.metadataHash),
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 2.takeIf { isLocalAccountSigner }
            )
        }
    }

    private fun createAssetCreationTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress) ?: return null
            val accountData = senderWalletConnectAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWalletConnectAddress, errorProvider)
            val isLocalAccountSigner = signer.address?.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.isThereAnyAccountWithPublicKey(safeAddress)
            } ?: false
            BaseAssetCreationTransaction.AssetCreationTransactionWithRekey(
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
                rekeyAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                totalAmount = assetConfigParams?.totalSupply ?: BigInteger.ZERO,
                decimals = assetConfigParams?.decimal ?: 0,
                isFrozen = assetConfigParams?.isFrozen ?: false,
                assetName = assetConfigParams?.name,
                unitName = assetConfigParams?.unitName,
                url = assetConfigParams?.url,
                metadataHash = encodeBase64EncodedHexString(assetConfigParams?.metadataHash),
                managerAddress = createWalletConnectAddress(assetConfigParams?.managerAddress),
                reserveAddress = createWalletConnectAddress(assetConfigParams?.reserveAddress),
                frozenAddress = createWalletConnectAddress(assetConfigParams?.frozenAddress),
                clawbackAddress = createWalletConnectAddress(assetConfigParams?.clawbackAddress),
                groupId = groupId,
                warningCount = 1.takeIf { isLocalAccountSigner }
            )
        }
    }
}
