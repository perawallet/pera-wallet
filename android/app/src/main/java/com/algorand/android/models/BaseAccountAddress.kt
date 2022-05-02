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
import com.algorand.android.utils.toShortenedAddress
import kotlinx.parcelize.Parcelize

sealed class BaseAccountAddress : Parcelable {

    abstract val publicKey: String
    abstract fun getDisplayAddress(): String

    @Parcelize
    data class AccountAddress(
        override val publicKey: String,
        val accountIcon: AccountIcon?,
        private val displayName: String?
    ) : BaseAccountAddress() {

        override fun getDisplayAddress(): String {
            return displayName ?: publicKey.toShortenedAddress()
        }
    }

    @Parcelize
    data class ContactAddress(
        override val publicKey: String,
        val displayName: String?,
        val imageUri: String?
    ) : BaseAccountAddress() {

        override fun getDisplayAddress(): String {
            return displayName.takeIf { it?.isNotBlank() == true } ?: publicKey.toShortenedAddress()
        }
    }
}
