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
import kotlinx.parcelize.Parcelize

sealed class BaseAppCallTransaction(appOnComplete: AppOnComplete) : BaseWalletConnectTransaction() {

    abstract val appArgs: List<String>?
    abstract val appId: Long?
    abstract val appOnComplete: AppOnComplete
    open val approvalHash: String? = null
    open val stateHash: String? = null

    override val summaryTitleResId: Int = appOnComplete.titleResId
    override val summarySecondaryParameter: String
        get() = appId.toString()

    @Parcelize
    data class AppOptInTransaction(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val senderAddress: WalletConnectAddress,
        override val appArgs: List<String>?,
        override val appId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val accountCacheData: AccountCacheData?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?
    ) : BaseAppCallTransaction(appOnComplete) {

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AppCallTransaction(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val senderAddress: WalletConnectAddress,
        override val appArgs: List<String>?,
        override val appId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val accountCacheData: AccountCacheData?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?
    ) : BaseAppCallTransaction(appOnComplete) {

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AppCallCreationTransaction(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val senderAddress: WalletConnectAddress,
        override val appArgs: List<String>?,
        override val appId: Long?,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val accountCacheData: AccountCacheData?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?,
        val appGlobalSchema: ApplicationCallStateSchema?,
        val appLocalSchema: ApplicationCallStateSchema?,
        val appExtraPages: Int?
    ) : BaseAppCallTransaction(appOnComplete) {

        override val summaryTitleResId: Int
            get() = R.string.application_creation

        override val summarySecondaryParameter: String
            get() = ""

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress) + signerAddressList.orEmpty()
        }
    }

    @Parcelize
    data class AppCallTransactionWithRekey(
        override val rawTransactionPayload: WCAlgoTransactionRequest,
        override val walletConnectTransactionParams: WalletConnectTransactionParams,
        override val note: String?,
        override val senderAddress: WalletConnectAddress,
        override val appArgs: List<String>?,
        override val appId: Long,
        override val peerMeta: WalletConnectPeerMeta,
        override val signer: WalletConnectSigner,
        override val accountCacheData: AccountCacheData?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?,
        val rekeyToAddress: WalletConnectAddress
    ) : BaseAppCallTransaction(appOnComplete) {

        override val shouldShowWarningIndicator: Boolean
            get() = true

        override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyToAddress

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, rekeyToAddress) + signerAddressList.orEmpty()
        }
    }

    @SuppressWarnings("MagicNumber")
    enum class AppOnComplete(val appOnCompleteNo: Int, val titleResId: Int, val displayTextResId: Int) {
        NO_OP(0, R.string.application_call_formatted, R.string.no_op),
        OPT_IN(1, R.string.application_opt_in_formatted, R.string.opt_in),
        CLOSE_OUT(2, R.string.application_close_to_formatted, R.string.close_out),
        CLEAR_STATE(3, R.string.application_call_formatted, R.string.clear_state),
        UPDATE(4, R.string.application_update_formatted, R.string.app_call_update),
        DELETE(5, R.string.application_delete_formatted, R.string.app_call_delete);

        companion object {
            fun isSupportedOnComplete(appOnCompleteNo: Int): Boolean {
                return values().firstOrNull { it.appOnCompleteNo == appOnCompleteNo } != null
            }

            fun getByAppNoOrDefault(appOnCompleteNo: Int?): AppOnComplete {
                return values().firstOrNull { it.appOnCompleteNo == appOnCompleteNo } ?: NO_OP
            }
        }
    }
}
