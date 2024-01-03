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

sealed class WalletConnectArbitraryDataSigner : Parcelable {

    open val address: String? = null

    open val isValidSigner: Boolean = false

    companion object {

        fun create(
            signerAccountType: Account.Type?,
            signerAddress: String,
            errorProvider: WalletConnectErrorProvider
        ): WalletConnectArbitraryDataSigner {
            return when {
                signerAddress.isNullOrBlank() -> {
                    DisplayOnly
                }

                else -> returnInvalidInputIfSignerIsInvalid(
                    signerAccountType,
                    Signer(signerAddress),
                    errorProvider.getInvalidPublicKeyError()
                )
            }
        }

        private fun returnInvalidInputIfSignerIsInvalid(
            signerAccountType: Account.Type?,
            signer: WalletConnectArbitraryDataSigner,
            error: WalletConnectError
        ): WalletConnectArbitraryDataSigner {
            return signer.takeIf {
                it.address?.isValidAddress() == true &&
                        (signerAccountType == Account.Type.STANDARD ||
                                signerAccountType == Account.Type.REKEYED ||
                                signerAccountType == Account.Type.REKEYED_AUTH)
            } ?: Unsignable(error)
        }
    }

    @Parcelize
    data class Signer(override val address: String) : WalletConnectArbitraryDataSigner() {
        override val isValidSigner: Boolean
            get() = true
    }

    @Parcelize
    data class Unsignable(val error: WalletConnectError) : WalletConnectArbitraryDataSigner() {
        override val isValidSigner: Boolean
            get() = false
    }

    @Parcelize
    object DisplayOnly : WalletConnectArbitraryDataSigner() {
        override val isValidSigner: Boolean
            get() = true
    }
}
