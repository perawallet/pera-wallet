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

package com.algorand.android.modules.walletconnect.subscription.domain

import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.subscription.v1.domain.SubscribeWalletConnectV1SessionUseCase
import javax.inject.Inject
import javax.inject.Named

class WalletConnectSessionSubscriptionManager @Inject constructor(
    @Named(SubscribeWalletConnectV1SessionUseCase.INJECTION_NAME)
    private val subscribeWalletConnectV1SessionUseCase: SubscribeWalletConnectSessionUseCase
) {

    suspend fun subscribe(sessionDetail: WalletConnect.SessionDetail, clientId: String) {
        getSubscriptionUseCase(sessionDetail.versionIdentifier).invoke(sessionDetail, clientId)
    }

    private fun getSubscriptionUseCase(
        versionIdentifier: WalletConnectVersionIdentifier
    ): SubscribeWalletConnectSessionUseCase {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> subscribeWalletConnectV1SessionUseCase
            WalletConnectVersionIdentifier.VERSION_2 -> TODO()
        }
    }
}
