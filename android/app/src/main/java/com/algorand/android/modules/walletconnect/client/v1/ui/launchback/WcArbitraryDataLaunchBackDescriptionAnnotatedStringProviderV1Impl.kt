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
import com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.model.WcRequestLaunchBackDescriptionAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier

class WcArbitraryDataLaunchBackDescriptionAnnotatedStringProviderV1Impl :
    WcRequestLaunchBackDescriptionAnnotatedStringProvider {

    override suspend fun provideAnnotatedString(
        sessionIdentifier: WalletConnectSessionIdentifier,
        peerName: String
    ): AnnotatedString {
        return AnnotatedString(
            stringResId = R.string.the_data_has_been_signed,
            replacementList = listOf("peer_name" to peerName)
        )
    }

    companion object {
        const val INJECTION_NAME = "wcArbitraryDataLaunchBackDescriptionAnnotatedStringV1InjectionName"
    }
}
