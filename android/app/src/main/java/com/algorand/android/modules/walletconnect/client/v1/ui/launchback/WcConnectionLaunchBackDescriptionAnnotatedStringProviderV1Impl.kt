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

package com.algorand.android.modules.walletconnect.client.v1.ui.launchback

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackDescriptionAnnotatedStringProvider

class WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl :
    WCConnectionLaunchBackDescriptionAnnotatedStringProvider {

    override suspend fun provideAnnotatedString(
        sessionDetail: WalletConnect.SessionDetail,
        launchBackBrowserItemCount: Int
    ): AnnotatedString {
        val peerName = sessionDetail.peerMeta.name
        return when (launchBackBrowserItemCount) {
            0, 1 -> {
                AnnotatedString(
                    stringResId = R.string.please_return_to,
                    replacementList = listOf("peer_name" to peerName)
                )
            }
            else -> {
                AnnotatedString(
                    stringResId = R.string.we_couldn_t_automatically_detect,
                    replacementList = listOf("peer_name" to peerName)
                )
            }
        }
    }

    companion object {
        const val INJECTION_NAME = "wcConnectionLaunchBackBrowserDescriptionAnnotatedStringV1InjectionName"
    }
}
