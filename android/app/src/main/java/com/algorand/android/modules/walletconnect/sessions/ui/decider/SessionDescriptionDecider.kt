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

package com.algorand.android.modules.walletconnect.sessions.ui.decider

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import javax.inject.Inject

class SessionDescriptionDecider @Inject constructor() {

    fun decideSessionDescription(
        versionIdentifier: WalletConnectVersionIdentifier,
        formattedConnectionDate: String,
        formattedExpirationDate: String?
    ): AnnotatedString {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> {
                createConnectedOnAnnotatedString(formattedConnectionDate)
            }
            WalletConnectVersionIdentifier.VERSION_2 -> {
                if (formattedExpirationDate != null) {
                    AnnotatedString(
                        stringResId = R.string.expires_on_date,
                        replacementList = listOf("expiration_date" to formattedExpirationDate)
                    )
                } else createConnectedOnAnnotatedString(formattedConnectionDate)
            }
        }
    }

    private fun createConnectedOnAnnotatedString(formattedConnectionDate: String): AnnotatedString {
        return AnnotatedString(
            stringResId = R.string.connected_on_date,
            replacementList = listOf("connection_date" to formattedConnectionDate)
        )
    }
}
