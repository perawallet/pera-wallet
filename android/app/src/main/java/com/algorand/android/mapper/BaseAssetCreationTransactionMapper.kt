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
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import com.algorand.android.utils.walletconnect.encodeBase64EncodedHexString
import java.math.BigInteger
import javax.inject.Inject

@SuppressWarnings("ReturnCount")
class BaseAssetCreationTransactionMapper @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val errorProvider: WalletConnectTransactionErrorProvider
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetCreationTransaction.AssetCreationTransaction(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
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
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetCreationTransaction.AssetCreationTransactionWithCloseTo(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
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
                groupId = groupId
            )
        }
    }

    private fun createAssetCreationTransactionWithCloseToAndRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransactionWithCloseToAndRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetCreationTransaction.AssetCreationTransactionWithCloseToAndRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
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
                groupId = groupId
            )
        }
    }

    private fun createAssetCreationTransactionWithRekey(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseAssetCreationTransaction.AssetCreationTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWalletConnectAddress = createWalletConnectAddress(senderAddress)
            val accountCacheData = accountCacheManager.getCacheData(senderWalletConnectAddress?.decodedAddress)
            BaseAssetCreationTransaction.AssetCreationTransactionWithRekey(
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                senderAddress = senderWalletConnectAddress ?: return null,
                note = decodedNote,
                peerMeta = peerMeta,
                rawTransactionPayload = rawTxn,
                signer = WalletConnectSigner.create(rawTxn, senderWalletConnectAddress, errorProvider),
                authAddress = accountCacheData?.authAddress,
                account = WalletConnectAccount.create(accountCacheData?.account),
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
                groupId = groupId
            )
        }
    }
}
