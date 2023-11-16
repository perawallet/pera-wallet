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

package com.algorand.android.models

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.utils.walletconnect.WalletConnectAssetDetail
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseAssetConfigurationTransaction : BaseWalletConnectTransaction() {

    abstract val assetId: Long?
    abstract val assetName: String?
    abstract val url: String?
    abstract val verificationTier: VerificationTier?

    sealed class BaseAssetCreationTransaction : BaseAssetConfigurationTransaction() {

        abstract val totalAmount: BigInteger?
        abstract val decimals: Long?
        abstract val isFrozen: Boolean?
        abstract val unitName: String?
        abstract val metadataHash: String?
        abstract val managerAddress: WalletConnectAddress?
        abstract val reserveAddress: WalletConnectAddress?
        abstract val frozenAddress: WalletConnectAddress?
        abstract val clawbackAddress: WalletConnectAddress?

        override val transactionAmount: BigInteger?
            get() = totalAmount

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        override val assetId: Long?
            get() = null

        override val verificationTier: VerificationTier?
            get() = null

        @Parcelize
        data class AssetCreationTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val fromAccount: WalletConnectAccount?,
            override val totalAmount: BigInteger? = null,
            override val decimals: Long? = null,
            override val isFrozen: Boolean? = null,
            override val assetName: String? = null,
            override val unitName: String? = null,
            override val url: String? = null,
            override val metadataHash: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?
        ) : BaseAssetCreationTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class AssetCreationTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val fromAccount: WalletConnectAccount?,
            override val totalAmount: BigInteger? = null,
            override val decimals: Long? = null,
            override val isFrozen: Boolean? = null,
            override val assetName: String? = null,
            override val unitName: String? = null,
            override val url: String? = null,
            override val metadataHash: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress
        ) : BaseAssetCreationTransaction() {

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class AssetCreationTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val fromAccount: WalletConnectAccount?,
            override val totalAmount: BigInteger? = null,
            override val decimals: Long? = null,
            override val isFrozen: Boolean? = null,
            override val assetName: String? = null,
            override val unitName: String? = null,
            override val url: String? = null,
            override val metadataHash: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetCreationTransaction() {

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class AssetCreationTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val fromAccount: WalletConnectAccount?,
            override val totalAmount: BigInteger? = null,
            override val decimals: Long? = null,
            override val isFrozen: Boolean? = null,
            override val assetName: String? = null,
            override val unitName: String? = null,
            override val url: String? = null,
            override val metadataHash: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetCreationTransaction() {

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        companion object {
            fun isTransactionWithCloseToAndRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return with(request) { !rekeyAddress.isNullOrBlank() && !assetCloseToAddress.isNullOrBlank() }
            }

            fun isTransactionWithCloseTo(request: WalletConnectTransactionRequest): Boolean {
                return request.assetCloseToAddress != null
            }

            fun isTransactionWithRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return request.rekeyAddress != null
            }
        }
    }

    sealed class BaseAssetReconfigurationTransaction : BaseAssetConfigurationTransaction(), WalletConnectAssetDetail {

        abstract val managerAddress: WalletConnectAddress?
        abstract val reserveAddress: WalletConnectAddress?
        abstract val frozenAddress: WalletConnectAddress?
        abstract val clawbackAddress: WalletConnectAddress?

        override var walletConnectTransactionAssetDetail: WalletConnectTransactionAssetDetail? = null

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        override val assetName: String?
            get() = walletConnectTransactionAssetDetail?.fullName

        val shortName: String?
            get() = walletConnectTransactionAssetDetail?.shortName

        override val verificationTier: VerificationTier?
            get() = walletConnectTransactionAssetDetail?.verificationTier

        @Parcelize
        data class AssetReconfigurationTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?
        ) : BaseAssetReconfigurationTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class AssetReconfigurationTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress
        ) : BaseAssetReconfigurationTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress
        }

        @Parcelize
        data class AssetReconfigurationTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetReconfigurationTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress
        }

        @Parcelize
        data class AssetReconfigurationTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetReconfigurationTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress
        }

        companion object {
            fun isTransactionWithCloseToAndRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return with(request) { !rekeyAddress.isNullOrBlank() && !assetCloseToAddress.isNullOrBlank() }
            }

            fun isTransactionWithCloseTo(request: WalletConnectTransactionRequest): Boolean {
                return request.assetCloseToAddress != null
            }

            fun isTransactionWithRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return request.rekeyAddress != null
            }
        }
    }

    sealed class BaseAssetDeletionTransaction : BaseAssetConfigurationTransaction(), WalletConnectAssetDetail {

        override var walletConnectTransactionAssetDetail: WalletConnectTransactionAssetDetail? = null

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        override val assetName: String?
            get() = walletConnectTransactionAssetDetail?.fullName

        val shortName: String?
            get() = walletConnectTransactionAssetDetail?.shortName

        override val verificationTier: VerificationTier?
            get() = walletConnectTransactionAssetDetail?.verificationTier

        @Parcelize
        data class AssetDeletionTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val groupId: String?,
            override val warningCount: Int?
        ) : BaseAssetDeletionTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class AssetDeletionTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress
        ) : BaseAssetDeletionTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress
        }

        @Parcelize
        data class AssetDeletionTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetDeletionTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress
        }

        @Parcelize
        data class AssetDeletionTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectTransactionSigner,
            override val authAddress: String?,
            override val assetInformation: WalletConnectAssetInformation?,
            override val fromAccount: WalletConnectAccount?,
            override val assetId: Long,
            override val url: String? = null,
            override val groupId: String?,
            override val warningCount: Int?,
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetDeletionTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress
        }

        companion object {
            fun isTransactionWithCloseToAndRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return with(request) { !rekeyAddress.isNullOrBlank() && !assetCloseToAddress.isNullOrBlank() }
            }

            fun isTransactionWithCloseTo(request: WalletConnectTransactionRequest): Boolean {
                return request.assetCloseToAddress != null
            }

            fun isTransactionWithRekeyed(request: WalletConnectTransactionRequest): Boolean {
                return request.rekeyAddress != null
            }
        }
    }

    companion object {
        fun isAssetCreationTransaction(request: WalletConnectTransactionRequest): Boolean {
            return request.assetIdBeingConfigured == 0L || request.assetIdBeingConfigured == null
        }

        fun isAssetReconfigurationTransaction(request: WalletConnectTransactionRequest): Boolean {
            return request.assetConfigParams != null && request.assetIdBeingConfigured != 0L
        }

        fun isAssetDeletion(request: WalletConnectTransactionRequest): Boolean {
            return request.assetConfigParams == null && request.assetIdBeingConfigured != 0L
        }
    }
}
