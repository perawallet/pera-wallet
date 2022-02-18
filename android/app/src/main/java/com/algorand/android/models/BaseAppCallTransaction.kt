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

import com.algorand.android.R
import kotlinx.parcelize.Parcelize

sealed class BaseAppCallTransaction : BaseWalletConnectTransaction() {

    abstract val appArgs: List<String>?
    abstract val appId: Long?
    abstract val appOnComplete: AppOnComplete
    open val approvalHash: String? = null
    open val stateHash: String? = null

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
        override val authAddress: String?,
        override val account: WalletConnectAccount?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?
    ) : BaseAppCallTransaction() {

        override val fee: Long
            get() = walletConnectTransactionParams.fee

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
        override val authAddress: String?,
        override val account: WalletConnectAccount?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?
    ) : BaseAppCallTransaction() {

        override val fee: Long
            get() = walletConnectTransactionParams.fee

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
        override val authAddress: String?,
        override val account: WalletConnectAccount?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?,
        val appGlobalSchema: ApplicationCallStateSchema?,
        val appLocalSchema: ApplicationCallStateSchema?,
        val appExtraPages: Int?
    ) : BaseAppCallTransaction() {

        override val fee: Long
            get() = walletConnectTransactionParams.fee

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
        override val authAddress: String?,
        override val account: WalletConnectAccount?,
        override val appOnComplete: AppOnComplete,
        override val approvalHash: String?,
        override val stateHash: String?,
        override val groupId: String?,
        override val warningCount: Int?,
        val rekeyToAddress: WalletConnectAddress
    ) : BaseAppCallTransaction() {

        override val fee: Long
            get() = walletConnectTransactionParams.fee

        override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyToAddress

        override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
            return listOf(senderAddress, rekeyToAddress) + signerAddressList.orEmpty()
        }
    }

    // TODO: 27.10.2021 On the design side, we have the Application Creation Transaction type but here,
    //  we don't receive that type of transaction.
    @SuppressWarnings("MagicNumber")
    enum class AppOnComplete(
        val appOnCompleteNo: Int,
        val titleResId: Int,
        val displayTextResId: Int,
        val summaryTitle: Int
    ) {
        NO_OP(0, R.string.application_call, R.string.no_op, R.string.application_call_with_id),
        OPT_IN(1, R.string.application_opt_in, R.string.opt_in, R.string.application_opt_in_with_id),
        CLOSE_OUT(2, R.string.application_close_to, R.string.close_out, R.string.application_close_to_with_id),
        CLEAR_STATE(3, R.string.application_call, R.string.clear_state, R.string.application_call_with_id),
        UPDATE(4, R.string.application_update, R.string.app_call_update, R.string.application_update_with_id),
        DELETE(5, R.string.application_delete, R.string.app_call_delete, R.string.application_delete_with_id);

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
