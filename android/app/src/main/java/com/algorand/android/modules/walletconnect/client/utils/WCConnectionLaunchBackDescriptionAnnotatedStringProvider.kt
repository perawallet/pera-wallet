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

import com.algorand.android.modules.walletconnect.client.v1.ui.launchback.WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl
import com.algorand.android.modules.walletconnect.client.v2.ui.launchback.connection.WCConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackDescriptionAnnotatedStringProvider
import javax.inject.Inject
import javax.inject.Named

class WCConnectionLaunchBackDescriptionAnnotatedStringProvider @Inject constructor(
    @Named(WcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl.INJECTION_NAME)
    private val wcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl:
    WCConnectionLaunchBackDescriptionAnnotatedStringProvider,
    @Named(WCConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl.INJECTION_NAME)
    private val wcConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl:
    WCConnectionLaunchBackDescriptionAnnotatedStringProvider,
) {

    fun provideDescriptionAnnotatedString(
        versionIdentifier: WalletConnectVersionIdentifier
    ): WCConnectionLaunchBackDescriptionAnnotatedStringProvider {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> wcConnectionLaunchBackDescriptionAnnotatedStringProviderV1Impl
            WalletConnectVersionIdentifier.VERSION_2 -> wcConnectionLaunchBackDescriptionAnnotatedStringProviderV2Impl
        }
    }
}
