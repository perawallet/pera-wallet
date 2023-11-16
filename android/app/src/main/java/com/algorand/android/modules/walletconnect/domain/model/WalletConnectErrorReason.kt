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

package com.algorand.android.modules.walletconnect.domain.model

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

sealed class WalletConnectErrorReason : Parcelable {

    abstract val category: WalletConnectErrorReasonCategory

    @Parcelize
    object UserRejected : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object FailedGroupingTransactions : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object PendingTransaction : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object RejectedChains : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object MismatchingNodes : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object MissingSecretKey : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnauthorizedMethod : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnauthorizedEvent : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnauthorizedChain : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnknownTransactionType : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object MultisigTransaction : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnsupportedChains : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object UnsupportedMethods : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object UnsupportedEvents : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object UnsupportedAccounts : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object UnsupportedNamespaceKey : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONNECTION_FAILED
    }

    @Parcelize
    object MaxTransactionLimit : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object MaxArbitraryDataLimit : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnableToParseTransaction : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnableToParseArbitraryData : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object InvalidPublicKey : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object InvalidAsset : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object UnableToSign : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object AtomicNoNeedToSign : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object MissingSigner : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.CONFIRMATION_FAILED
    }

    @Parcelize
    object SessionNotFound : WalletConnectErrorReason() {

        override val category: WalletConnectErrorReasonCategory
            get() = WalletConnectErrorReasonCategory.WC_SESSION_NOT_FOUND
    }
}
