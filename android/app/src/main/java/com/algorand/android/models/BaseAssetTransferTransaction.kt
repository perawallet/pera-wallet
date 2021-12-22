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

package com.algorand.android.models

import com.algorand.android.R
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.walletconnect.WalletConnectAssetDetail
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseAssetTransferTransaction : BaseWalletConnectTransaction(), WalletConnectAssetDetail {

    abstract val assetReceiverAddress: WalletConnectAddress
    override var assetParams: AssetParams? = null

    override val summaryTitleResId: Int = R.string.asset_transfer_formatted
    override val summarySecondaryParameter: String
        get() = assetReceiverAddress.decodedAddress.toShortenedAddress()

    override val assetDecimal: Int
        get() = assetParams?.decimals ?: DEFAULT_ASSET_DECIMAL

    @Parcelize
    data class AssetTransferTransaction(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val assetReceiverAddress: WalletConnectAddress,
        override val senderAddress: WalletConnectAddress,
        override val assetId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val authAddress: String?,
        override val assetInformation: WalletConnectAssetInformation?,
        override val account: WalletConnectAccount?,
        override val groupId: String?,
        val assetAmount: BigInteger
    ) : BaseAssetTransferTransaction() {

        override val transactionAmount: BigInteger
            get() = assetAmount

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, assetReceiverAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AssetTransferTransactionWithClose(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val assetReceiverAddress: WalletConnectAddress,
        override val senderAddress: WalletConnectAddress,
        override val assetId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val authAddress: String?,
        override val assetInformation: WalletConnectAssetInformation?,
        override val account: WalletConnectAccount?,
        override val groupId: String?,
        val assetCloseToAddress: WalletConnectAddress,
        val assetAmount: BigInteger
    ) : BaseAssetTransferTransaction() {

        override val shouldShowWarningIndicator: Boolean
            get() = true

        override val transactionAmount: BigInteger
            get() = assetAmount

        override fun getCloseToAccountAddress(): WalletConnectAddress = assetCloseToAddress

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, assetReceiverAddress, assetCloseToAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AssetTransferTransactionWithRekey(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val assetReceiverAddress: WalletConnectAddress,
        override val senderAddress: WalletConnectAddress,
        override val assetId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val authAddress: String?,
        override val assetInformation: WalletConnectAssetInformation?,
        override val account: WalletConnectAccount?,
        override val groupId: String?,
        val rekeyAddress: WalletConnectAddress,
        val assetAmount: BigInteger
    ) : BaseAssetTransferTransaction() {

        override val shouldShowWarningIndicator: Boolean
            get() = true

        override val transactionAmount: BigInteger
            get() = assetAmount

        override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, assetReceiverAddress, rekeyAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AssetTransferTransactionWithRekeyAndClose(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val assetReceiverAddress: WalletConnectAddress,
        override val senderAddress: WalletConnectAddress,
        override val assetId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val authAddress: String?,
        override val assetInformation: WalletConnectAssetInformation?,
        override val account: WalletConnectAccount?,
        override val groupId: String?,
        val rekeyAddress: WalletConnectAddress,
        val assetAmount: BigInteger,
        val closeAddress: WalletConnectAddress
    ) : BaseAssetTransferTransaction() {

        override val shouldShowWarningIndicator: Boolean
            get() = true

        override val transactionAmount: BigInteger
            get() = assetAmount

        override fun getCloseToAccountAddress(): WalletConnectAddress = closeAddress

        override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, assetReceiverAddress, rekeyAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AssetOptInTransaction(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val senderAddress: WalletConnectAddress,
        override val assetReceiverAddress: WalletConnectAddress,
        override val assetId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val authAddress: String?,
        override val assetInformation: WalletConnectAssetInformation?,
        override val account: WalletConnectAccount?,
        override val groupId: String?
    ) : BaseAssetTransferTransaction() {

        override val transactionAmount: BigInteger?
            get() = BigInteger.ZERO

        override val summaryTitleResId: Int
            get() = R.string.possible_opt_in_formatted

        override val summarySecondaryParameter: String
            get() = assetId.toString()

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, assetReceiverAddress) + signerAddressList.orEmpty()
        }
    }
}
