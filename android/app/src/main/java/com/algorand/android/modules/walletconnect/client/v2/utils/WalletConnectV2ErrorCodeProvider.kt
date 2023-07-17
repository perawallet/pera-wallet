@file:Suppress("MagicNumber")
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

package com.algorand.android.modules.walletconnect.client.v2.utils

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectErrorReason
import javax.inject.Inject

class WalletConnectV2ErrorCodeProvider @Inject constructor() {

    fun getErrorCode(error: WalletConnectErrorReason): Long {
        return when (error) {
            is WalletConnectErrorReason.AtomicNoNeedToSign -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.FailedGroupingTransactions -> USER_REJECTED_ERROR_CODE
            is WalletConnectErrorReason.InvalidAsset -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.InvalidPublicKey -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.MaxTransactionLimit -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.MismatchingNodes -> UNAUTHORIZED_CHAIN
            is WalletConnectErrorReason.MissingSecretKey -> UNSUPPORTED_ACCOUNTS_ERROR_CODE
            is WalletConnectErrorReason.MissingSigner -> UNSUPPORTED_ACCOUNTS_ERROR_CODE
            is WalletConnectErrorReason.MultisigTransaction -> UNSUPPORTED_METHODS_ERROR_CODE
            is WalletConnectErrorReason.PendingTransaction -> USER_REJECTED_ERROR_CODE
            is WalletConnectErrorReason.RejectedChains -> USER_REJECTED_CHAINS_ERROR_CODE
            is WalletConnectErrorReason.SessionNotFound -> NO_SESSION_FOR_TOPIC_ERROR_CODE
            is WalletConnectErrorReason.UnableToParseTransaction -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.UnableToSign -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.UnauthorizedChain -> UNAUTHORIZED_CHAIN
            is WalletConnectErrorReason.UnauthorizedEvent -> UNAUTHORIZED_EVENT
            is WalletConnectErrorReason.UnauthorizedMethod -> UNAUTHORIZED_METHOD
            is WalletConnectErrorReason.UnknownTransactionType -> INVALID_METHOD_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedAccounts -> UNSUPPORTED_ACCOUNTS_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedChains -> UNSUPPORTED_CHAIN_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedEvents -> UNSUPPORTED_EVENT_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedMethods -> UNSUPPORTED_METHODS_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedNamespaceKey -> UNSUPPORTED_NAMESPACE_KEY_ERROR_CODE
            is WalletConnectErrorReason.UserRejected -> USER_REJECTED_ERROR_CODE
        }
    }

    companion object {
        private const val INVALID_METHOD_ERROR_CODE = 1001L

        private const val UNAUTHORIZED_METHOD = 3001L
        private const val UNAUTHORIZED_EVENT = 3002L
        private const val UNAUTHORIZED_CHAIN = 3005L

        private const val USER_REJECTED_ERROR_CODE = 5000L
        private const val USER_REJECTED_CHAINS_ERROR_CODE = 5001L

        private const val UNSUPPORTED_CHAIN_ERROR_CODE = 5100L
        private const val UNSUPPORTED_METHODS_ERROR_CODE = 5101L
        private const val UNSUPPORTED_EVENT_ERROR_CODE = 5102L
        private const val UNSUPPORTED_ACCOUNTS_ERROR_CODE = 5103L
        private const val UNSUPPORTED_NAMESPACE_KEY_ERROR_CODE = 5103L

        private const val NO_SESSION_FOR_TOPIC_ERROR_CODE = 7001L
    }
}
