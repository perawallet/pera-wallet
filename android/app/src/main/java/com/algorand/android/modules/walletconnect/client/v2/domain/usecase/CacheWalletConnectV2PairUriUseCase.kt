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

import com.algorand.android.modules.walletconnect.client.v2.domain.model.mapper.WalletConnectV2PairUriMapper
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2UriValidator
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import javax.inject.Named

class CacheWalletConnectV2PairUriUseCase @Inject constructor(
    @Named(WalletConnectV2Repository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectV2Repository,
    private val walletConnectV2PairUriMapper: WalletConnectV2PairUriMapper
) {

    suspend operator fun invoke(uri: String) {
        val pairingTopic = parsePairingTopic(uri) ?: return
        val pairUri = walletConnectV2PairUriMapper.mapToPairUri(
            pairingTopic = pairingTopic,
            connectionUri = uri
        )
        val cacheResult = CacheResult.Success.create(pairUri)
        walletConnectRepository.cachePairUri(cacheResult)
    }

    private fun parsePairingTopic(uri: String): String? {
        val walletConnectUri = WalletConnectV2UriValidator.createWalletConnectUri(uri) ?: return null
        return walletConnectUri.topic.value
    }
}
