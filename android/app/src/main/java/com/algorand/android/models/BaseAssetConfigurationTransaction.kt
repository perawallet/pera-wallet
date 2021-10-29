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

import android.content.Context
import android.text.SpannableStringBuilder
import com.algorand.android.R
import com.algorand.android.utils.addUnnamedAssetName
import com.algorand.android.utils.walletconnect.WalletConnectAssetDetail
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class BaseAssetConfigurationTransaction : BaseWalletConnectTransaction() {

    abstract override val summaryTitleResId: Int
    abstract override val walletConnectTransactionParams: WalletConnectTransactionParams
    abstract override val senderAddress: WalletConnectAddress
    abstract override val note: String?
    abstract override val peerMeta: WalletConnectPeerMeta
    abstract override val rawTransactionPayload: WCAlgoTransactionRequest
    abstract override val signer: WalletConnectSigner
    abstract override val accountCacheData: AccountCacheData?
    abstract val screenTitleResId: Int

    override val summarySecondaryParameter: String
        get() = ""

    sealed class BaseAssetCreationTransaction : BaseAssetConfigurationTransaction() {

        abstract val totalAmount: BigInteger?
        abstract val decimals: Long?
        abstract val isFrozen: Boolean?
        abstract val assetName: String?
        abstract val unitName: String?
        abstract val url: String?
        abstract val metadataHash: String?
        abstract val managerAddress: WalletConnectAddress?
        abstract val reserveAddress: WalletConnectAddress?
        abstract val frozenAddress: WalletConnectAddress?
        abstract val clawbackAddress: WalletConnectAddress?

        override val screenTitleResId: Int
            get() = R.string.asset_creation_request

        override val transactionAmount: BigInteger?
            get() = totalAmount

        override val summaryTitleResId: Int
            get() = R.string.asset_creation_request

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        fun getAssetName(context: Context): String {
            return SpannableStringBuilder().apply {
                if (!assetName.isNullOrBlank()) append(assetName) else addUnnamedAssetName(context)
            }.toString()
        }

        fun getUnitName(context: Context): String {
            return SpannableStringBuilder().apply {
                if (!unitName.isNullOrBlank()) append(unitName) else addUnnamedAssetName(context)
            }.toString()
        }

        @Parcelize
        data class AssetCreationTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
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
        ) : BaseAssetCreationTransaction()

        @Parcelize
        data class AssetCreationTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
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
            val closeToAddress: WalletConnectAddress
        ) : BaseAssetCreationTransaction() {

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress

            override val shouldShowWarningIndicator: Boolean
                get() = true
        }

        @Parcelize
        data class AssetCreationTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
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
            val rekeyAddress: WalletConnectAddress
        ) : BaseAssetCreationTransaction() {

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

            override val shouldShowWarningIndicator: Boolean
                get() = true
        }

        @Parcelize
        data class AssetCreationTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
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
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress,
        ) : BaseAssetCreationTransaction() {

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress

            override val shouldShowWarningIndicator: Boolean
                get() = true
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

        abstract val url: String?
        abstract val managerAddress: WalletConnectAddress?
        abstract val reserveAddress: WalletConnectAddress?
        abstract val frozenAddress: WalletConnectAddress?
        abstract val clawbackAddress: WalletConnectAddress?

        override val screenTitleResId: Int
            get() = R.string.asset_reconfiguration_request

        override val summaryTitleResId: Int
            get() = R.string.asset_reconfiguration_request

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        @Parcelize
        data class AssetReconfigurationTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
        ) : BaseAssetReconfigurationTransaction()

        @Parcelize
        data class AssetReconfigurationTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val closeToAddress: WalletConnectAddress,
        ) : BaseAssetReconfigurationTransaction() {

            override val shouldShowWarningIndicator: Boolean
                get() = true

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress
        }

        @Parcelize
        data class AssetReconfigurationTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val rekeyAddress: WalletConnectAddress,
        ) : BaseAssetReconfigurationTransaction() {

            override val shouldShowWarningIndicator: Boolean
                get() = true

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress
        }

        @Parcelize
        data class AssetReconfigurationTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override val managerAddress: WalletConnectAddress? = null,
            override val reserveAddress: WalletConnectAddress? = null,
            override val frozenAddress: WalletConnectAddress? = null,
            override val clawbackAddress: WalletConnectAddress? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress,
        ) : BaseAssetReconfigurationTransaction() {

            override val shouldShowWarningIndicator: Boolean
                get() = true

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

        abstract val url: String?

        override val screenTitleResId: Int
            get() = R.string.asset_deletion_request

        override val summaryTitleResId: Int
            get() = R.string.asset_deletion_request

        override val shouldShowWarningIndicator: Boolean
            get() = true

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }

        @Parcelize
        data class AssetDeletionTransaction(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?
        ) : BaseAssetDeletionTransaction()

        @Parcelize
        data class AssetDeletionTransactionWithCloseTo(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val closeToAddress: WalletConnectAddress,
        ) : BaseAssetDeletionTransaction() {

            override fun getCloseToAccountAddress(): WalletConnectAddress = closeToAddress
        }

        @Parcelize
        data class AssetDeletionTransactionWithRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val rekeyAddress: WalletConnectAddress,
        ) : BaseAssetDeletionTransaction() {

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyAddress
        }

        @Parcelize
        data class AssetDeletionTransactionWithCloseToAndRekey(
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val senderAddress: WalletConnectAddress,
            override val note: String?,
            override val peerMeta: WalletConnectPeerMeta,
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val signer: WalletConnectSigner,
            override val accountCacheData: AccountCacheData?,
            override val assetId: Long,
            override val url: String? = null,
            override var assetParams: AssetParams? = null,
            override val groupId: String?,
            val closeToAddress: WalletConnectAddress,
            val rekeyAddress: WalletConnectAddress,
        ) : BaseAssetDeletionTransaction() {

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
