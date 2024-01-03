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

package com.algorand.android.modules.walletconnect.client.v1.utils

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectErrorReason
import javax.inject.Inject

class WalletConnectV1ErrorCodeProvider @Inject constructor() {

    fun getErrorCode(error: WalletConnectErrorReason): Long {
        return when (error) {
            is WalletConnectErrorReason.AtomicNoNeedToSign -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.FailedGroupingTransactions -> REJECTED_ERROR_CODE
            is WalletConnectErrorReason.InvalidAsset -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.InvalidPublicKey -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.MaxTransactionLimit -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.MismatchingNodes -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.MissingSecretKey -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.MissingSigner -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.MultisigTransaction -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.PendingTransaction -> REJECTED_ERROR_CODE
            is WalletConnectErrorReason.RejectedChains -> REJECTED_ERROR_CODE
            is WalletConnectErrorReason.SessionNotFound -> REJECTED_ERROR_CODE
            is WalletConnectErrorReason.UnableToParseTransaction -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.UnableToSign -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.UnauthorizedChain -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.UnauthorizedEvent -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.UnauthorizedMethod -> UNAUTHORIZED_ERROR_CODE
            is WalletConnectErrorReason.UnknownTransactionType -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedAccounts -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedChains -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedEvents -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedMethods -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UnsupportedNamespaceKey -> UNSUPPORTED_ERROR_CODE
            is WalletConnectErrorReason.UserRejected -> REJECTED_ERROR_CODE
            is WalletConnectErrorReason.MaxArbitraryDataLimit -> INVALID_INPUT_ERROR_CODE
            is WalletConnectErrorReason.UnableToParseArbitraryData -> INVALID_INPUT_ERROR_CODE
        }
    }

    companion object {
        private const val REJECTED_ERROR_CODE = 4100L
        private const val UNAUTHORIZED_ERROR_CODE = 4100L
        private const val UNSUPPORTED_ERROR_CODE = 4200L
        private const val INVALID_INPUT_ERROR_CODE = 4300L
    }
}
