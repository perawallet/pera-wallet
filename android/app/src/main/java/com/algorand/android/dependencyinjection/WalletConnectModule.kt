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

package com.algorand.android.dependencyinjection

import android.content.Context
import com.algorand.android.R
import com.algorand.android.models.BaseWalletConnectErrorProvider
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.walletconnect.WalletConnectCustomTransactionHandler.Companion.MAX_TRANSACTION_COUNT
import com.algorand.android.utils.walletconnect.WalletConnectEventLogger
import com.algorand.android.utils.walletconnect.WalletConnectFirebaseEventLogger
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import com.google.firebase.analytics.FirebaseAnalytics
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WalletConnectModule {

    @Provides
    fun provideWalletConnectEventLogger(
        firebaseAnalytics: FirebaseAnalytics,
        algodInterceptor: AlgodInterceptor
    ): WalletConnectEventLogger {
        return WalletConnectFirebaseEventLogger(firebaseAnalytics, algodInterceptor)
    }

    @Singleton
    @Provides
    fun provideWalletConnectTransactionErrorProvider(
        @ApplicationContext appContext: Context
    ): WalletConnectTransactionErrorProvider {
        return with(appContext) {
            val rejectedErrorProvider = BaseWalletConnectErrorProvider.RequestRejectedErrorProvider(
                userRejectionErrorMessage = getString(R.string.transaction_request_rejected_user_rejected),
                failedGroupTransactionErrorMessage = getString(R.string.it_looks_like),
                pendingTransactionErrorMessage = getString(R.string.transaction_request_rejected_user_currently)
            )

            val unauthorizedRequestErrorProvider = BaseWalletConnectErrorProvider.UnauthorizedRequestErrorProvider(
                mismatchingNodesErrorMessage = getString(R.string.signing_error_network_mismatch),
                missingSignerErrorMessage = getString(R.string.signing_error_transaction_in_request)
            )

            val unsupportedErrorProvider = BaseWalletConnectErrorProvider.UnsupportedRequestErrorProvider(
                unknownTransactionTypeErrorMessage = getString(R.string.transaction_request_contains_unsupported),
                multisigTransactionErrorMessage = getString(R.string.transaction_request_contains_unsupported_multisig)
            )

            val invalidInputErrorProvider = BaseWalletConnectErrorProvider.InvalidInputErrorProvider(
                maxTransactionLimitErrorMessage = getString(
                    R.string.invalid_input_transaction_request,
                    MAX_TRANSACTION_COUNT
                ),
                unableToParseErrorMessage = getString(R.string.invalid_input_unable_to_parse),
                invalidPublicKeyErrorMessage = getString(R.string.invalid_input_invalid_public_key),
                invalidAssetErrorMessage = getString(R.string.invalid_input_invalid_asset),
                unableToSignErrorMessage = getString(R.string.invalid_input_unable_to_be),
                atomicTxnNoNeedToBeSignedErrorMessage = getString(R.string.invalid_input_group_transaction),
                invalidSignerErrorMessage = getString(R.string.invalid_input_requested_signer),
            )

            WalletConnectTransactionErrorProvider(
                rejected = rejectedErrorProvider,
                unauthorized = unauthorizedRequestErrorProvider,
                unsupported = unsupportedErrorProvider,
                invalidInput = invalidInputErrorProvider
            )
        }
    }
}
