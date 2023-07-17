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

package com.algorand.android.modules.walletconnect.client.v2.domain.usecase

import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.utils.walletconnect.getFallBackBrowserFromWCUrlOrNull
import javax.inject.Inject
import javax.inject.Named

class GetWalletConnectV2LaunchBackBrowserGroupUseCase @Inject constructor(
    @Named(WalletConnectV2Repository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectV2Repository
) {

    suspend operator fun invoke(pairTopic: String): String? {
        val cachedPairUri = walletConnectRepository.getCachedPairUris().firstOrNull { cachedPairUri ->
            cachedPairUri.data?.pairingTopic == pairTopic
        }?.data ?: return null

        return cachedPairUri.connectionUri.getFallBackBrowserFromWCUrlOrNull()
    }
}
