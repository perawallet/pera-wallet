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
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectError
import com.algorand.android.utils.isValidAddress
import kotlinx.parcelize.Parcelize

sealed class WalletConnectSigner : Parcelable {

    open val address: WalletConnectAddress? = null

    open val isValidSigner: Boolean = false

    companion object {

        fun create(
            transactionRequest: WCAlgoTransactionRequest,
            senderAddress: WalletConnectAddress,
            errorProvider: WalletConnectErrorProvider
        ): WalletConnectSigner {
            return with(transactionRequest) {
                when {
                    hasMultisig -> Multisig(errorProvider.getMultisigTransactionError())
                    hasMultipleSigner -> Unsignable(errorProvider.getUnknownTransactionType())
                    isDisplayOnly -> DisplayOnly
                    firstSignerAddress != null && authAccountAddress != null -> {
                        return if (authAccountAddress == firstSignerAddress) {
                            returnInvalidInputIfAddressIsInvalid(
                                Rekeyed(WalletConnectAddress(authAccountAddress, authAccountAddress)),
                                errorProvider.getInvalidPublicKeyError()
                            )
                        } else {
                            Unsignable(errorProvider.getUnableToSignError())
                        }
                    }
                    firstSignerAddress != null -> {
                        return if (senderAddress.decodedAddress == firstSignerAddress) {
                            returnInvalidInputIfAddressIsInvalid(
                                Sender(senderAddress),
                                errorProvider.getInvalidPublicKeyError()
                            )
                        } else {
                            Unsignable(errorProvider.getUnableToSignError())
                        }
                    }
                    authAccountAddress != null -> {
                        returnInvalidInputIfAddressIsInvalid(
                            Rekeyed(WalletConnectAddress(authAccountAddress, authAccountAddress)),
                            errorProvider.getInvalidPublicKeyError()
                        )
                    }
                    else -> returnInvalidInputIfAddressIsInvalid(
                        Sender(senderAddress),
                        errorProvider.getInvalidPublicKeyError()
                    )
                }
            }
        }

        private fun returnInvalidInputIfAddressIsInvalid(
            signer: WalletConnectSigner,
            error: WalletConnectError
        ): WalletConnectSigner {
            return signer.takeIf { it.address?.decodedAddress?.isValidAddress() == true } ?: Unsignable(error)
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
    data class Unsignable(val error: WalletConnectError) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = false
    }

    @Parcelize
    data class Multisig(val error: WalletConnectError) : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = false
    }

    @Parcelize
    object DisplayOnly : WalletConnectSigner() {
        override val isValidSigner: Boolean
            get() = true
    }
}
