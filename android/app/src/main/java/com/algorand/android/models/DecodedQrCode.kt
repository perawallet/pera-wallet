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
import androidx.annotation.StringRes
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

sealed class DecodedQrCode : Parcelable {

    sealed class Success : DecodedQrCode() {
        @Parcelize
        data class Mnemonic(val mnemonic: String?) : Success()

        @Parcelize
        data class AccountPublicKey(val address: String?) : Success()

        sealed class Deeplink : Success() {
            @Parcelize
            data class AssetTransaction(
                val address: String,
                val amount: BigInteger,
                val note: String?,
                val xnote: String?,
                val label: String?,
                private val assetId: Long?
            ) : Deeplink() {
                fun getDecodedAssetID(): Long {
                    return assetId ?: AssetInformation.ALGO_ID
                }
            }

            @Parcelize
            data class WalletConnect(val walletConnectUrl: String) : Deeplink()

            @Parcelize
            data class AddContact(val contactPublicKey: String, val contactName: String?) : Deeplink()

            @Parcelize
            data class MoonPayResult(val address: String, val transactionStatus: String, val transactionId: String?) :
                Deeplink()
        }
    }

    sealed class Error : DecodedQrCode() {
        abstract val titleRes: Int

        @Parcelize
        data class WalletConnect(@StringRes override val titleRes: Int) : Error()

        @Parcelize
        data class Mnemonic(@StringRes override val titleRes: Int) : Error()

        @Parcelize
        data class PublicKey(@StringRes override val titleRes: Int) : Error()
    }
}
