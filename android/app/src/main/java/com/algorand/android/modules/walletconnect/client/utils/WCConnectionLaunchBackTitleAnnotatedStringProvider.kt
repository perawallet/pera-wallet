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

package com.algorand.android.modules.walletconnect.client.utils

import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection.WCConnectionLaunchBackTitleAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WcConnectionLaunchBackTitleAnnotatedStringProvider
import javax.inject.Inject
import javax.inject.Named

class WCConnectionLaunchBackTitleAnnotatedStringProvider @Inject constructor(
    @Named(WcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl.INJECTION_NAME)
    private val wcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl:
    WcConnectionLaunchBackTitleAnnotatedStringProvider,
    @Named(WCConnectionLaunchBackTitleAnnotatedStringProviderV2Impl.INJECTION_NAME)
    private val wcConnectionLaunchBackTitleAnnotatedStringProviderV2Impl:
    WcConnectionLaunchBackTitleAnnotatedStringProvider
) {

    fun provideTitleAnnotatedString(
        versionIdentifier: WalletConnectVersionIdentifier
    ): WcConnectionLaunchBackTitleAnnotatedStringProvider {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> wcConnectionLaunchBackTitleAnnotatedStringProviderV1Impl
            WalletConnectVersionIdentifier.VERSION_2 -> wcConnectionLaunchBackTitleAnnotatedStringProviderV2Impl
        }
    }
}
