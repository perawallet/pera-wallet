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

import android.os.Parcelable
import com.algorand.android.utils.isValidAddress
import com.algorand.android.utils.walletconnect.WalletConnectTransactionErrorProvider
import kotlinx.parcelize.Parcelize

sealed class WalletConnectSigner : Parcelable {

    open val address: WalletConnectAddress? = null

    open val isValidSigner: Boolean = false

    companion object {

        fun create(
            transactionRequest: WCAlgoTransactionRequest,
            senderAddress: WalletConnectAddress,
            errorProvider: WalletConnectTransactionErrorProvider
        ): WalletConnectSigner {
            return with(transactionRequest) {
                when {
                    hasMultisig -> Multisig(errorProvider.unsupported.multisigTransaction)
                    hasMultipleSigner -> Unsignable(errorProvider.unsupported.unknownTransactionType)
                    isDisplayOnly -> DisplayOnly
                    firstSignerAddressBase64 != null && authAddressBase64 != null -> {
                        return if (authAddressBase64 == firstSignerAddressBase64) {
                            returnInvalidInputIfAddressIsInvalid(
                                Rekeyed(WalletConnectAddress.create(authAddressBase64)),
                                errorProvider.invalidInput.invalidPublicKey
                            )
                        } else {
                            Unsignable(errorProvider.invalidInput.unableToSign)
                        }
                    }
                    firstSignerAddressBase64 != null -> {
                        return if (senderAddress.addressBase64 == firstSignerAddressBase64) {
                            returnInvalidInputIfAddressIsInvalid(
                                Sender(senderAddress),
                                errorProvider.invalidInput.invalidPublicKey
                            )
                        } else {
                            Unsignable(errorProvider.invalidInput.unableToSign)
                        }
                    }
                    authAddressBase64 != null -> {
                        returnInvalidInputIfAddressIsInvalid(
                            Rekeyed(WalletConnectAddress.create(authAddressBase64)),
                            errorProvider.invalidInput.invalidPublicKey
                        )
                    }
                    else -> returnInvalidInputIfAddressIsInvalid(
                        Sender(senderAddress),
                        errorProvider.invalidInput.invalidPublicKey
                    )
                }
            }
        }

        private fun returnInvalidInputIfAddressIsInvalid(
            signer: WalletConnectSigner,
            errorResponse: WalletConnectTransactionErrorResponse
        ): WalletConnectSigner {
            return signer.takeIf { it.address?.decodedAddress?.isValidAddress() == true } ?: Unsignable(errorResponse)
        }
    }

    @Parcelize
    data class Sender(override val address: WalletConnectAddress) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = true
    }

    @Parcelize
    data class Rekeyed(override val address: WalletConnectAddress) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = true
    }

    @Parcelize
    data class Unsignable(val errorResponse: WalletConnectTransactionErrorResponse) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = false
    }

    @Parcelize
    data class Multisig(val errorResponse: WalletConnectTransactionErrorResponse) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = false
    }

    @Parcelize
    object DisplayOnly : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = true
    }
}
