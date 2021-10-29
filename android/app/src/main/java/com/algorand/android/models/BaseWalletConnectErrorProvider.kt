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

sealed class BaseWalletConnectErrorProvider {

    protected abstract fun getError(errorMessage: String): WalletConnectTransactionErrorResponse

    class RequestRejectedErrorProvider(
        private val userRejectionErrorMessage: String,
        private val failedGroupTransactionErrorMessage: String,
        private val pendingTransactionErrorMessage: String
    ) : BaseWalletConnectErrorProvider() {

        /**
         * The User has rejected the transaction request.
         */
        val userRejection
            get() = getError(userRejectionErrorMessage)

        /**
         * The transaction group has failed validation by the Algorand SDK.
         */
        val failedGroupTransaction
            get() = getError(failedGroupTransactionErrorMessage)

        /**
         * The User currently has another transaction request that is in progress.
         */
        val pendingTransaction
            get() = getError(pendingTransactionErrorMessage)

        override fun getError(errorMessage: String): WalletConnectTransactionErrorResponse {
            return WalletConnectTransactionErrorResponse.Rejected(errorMessage)
        }
    }

    class UnauthorizedRequestErrorProvider(
        private val mismatchingNodesErrorMessage: String,
        private val missingSignerErrorMessage: String
    ) : BaseWalletConnectErrorProvider() {

        /**
         * Network mismatch between dApp and Wallet.
         * For example, Wallet is connected to TestNet and dApp connected to MainNet (or vice versa).
         */
        val mismatchingNodes
            get() = getError(mismatchingNodesErrorMessage)

        /**
         *  A transaction in the transaction request requires
         *  a private key (signer) that does not exist in the connected Wallet.
         */
        val missingSigner
            get() = getError(missingSignerErrorMessage)

        override fun getError(errorMessage: String): WalletConnectTransactionErrorResponse {
            return WalletConnectTransactionErrorResponse.Unauthorized(errorMessage)
        }
    }

    class UnsupportedRequestErrorProvider(
        private val unknownTransactionTypeErrorMessage: String,
        private val multisigTransactionErrorMessage: String
    ) : BaseWalletConnectErrorProvider() {

        /**
         * The transaction request contains an Unsupported Transaction Type
         */
        val unknownTransactionType
            get() = getError(unknownTransactionTypeErrorMessage)

        /**
         * The transaction request contains an Unsupported Transaction Type: Multi-sig
         */
        val multisigTransaction
            get() = getError(multisigTransactionErrorMessage)

        override fun getError(errorMessage: String): WalletConnectTransactionErrorResponse {
            return WalletConnectTransactionErrorResponse.Unsupported(errorMessage)
        }
    }

    class InvalidInputErrorProvider(
        private val maxTransactionLimitErrorMessage: String,
        private val unableToParseErrorMessage: String,
        private val invalidPublicKeyErrorMessage: String,
        private val invalidAssetErrorMessage: String,
        private val unableToSignErrorMessage: String,
        private val atomicTxnNoNeedToBeSignedErrorMessage: String,
        private val invalidSignerErrorMessage: String
    ) : BaseWalletConnectErrorProvider() {

        override fun getError(errorMessage: String): WalletConnectTransactionErrorResponse {
            return WalletConnectTransactionErrorResponse.InvalidInput(errorMessage)
        }

        /**
         *  Transaction request contains more than 16 transactions
         */
        val maxTransactionLimit
            get() = getError(maxTransactionLimitErrorMessage)

        /**
         * Unable to parse transaction
         */
        val unableToParse
            get() = getError(unableToParseErrorMessage)

        /**
         *  Transaction contains invalid public key
         */
        val invalidPublicKey
            get() = getError(invalidPublicKeyErrorMessage)

        /**
         * Transaction contains invalid asset
         */
        val invalidAsset
            get() = getError(invalidAssetErrorMessage)

        /**
         *  Unable to be signed
         */
        val unableToSign
            get() = getError(unableToSignErrorMessage)

        /**
         *  Group/Atomic transaction does not need to be signed by Wallet user.
         */
        val atomicTxnNoNeedToBeSigned
            get() = getError(atomicTxnNoNeedToBeSignedErrorMessage)

        /**
         *  The requested signer is not in the User Wallet
         */
        val invalidSigner
            get() = getError(invalidSignerErrorMessage)
    }
}
