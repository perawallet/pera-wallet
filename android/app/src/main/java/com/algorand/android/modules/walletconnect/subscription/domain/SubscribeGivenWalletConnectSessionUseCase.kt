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

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.modules.walletconnect.subscription.data.mapper.WalletConnectSessionSubscriptionBodyMapper
import com.algorand.android.modules.walletconnect.subscription.data.model.WalletConnectSessionSubscriptionBody
import com.algorand.android.modules.walletconnect.subscription.data.usecase.SetGivenSessionAsSubscribedUseCase
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.filter

class SubscribeGivenWalletConnectSessionUseCase @Inject constructor(
    private val firebasePushTokenUseCase: FirebasePushTokenUseCase,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val setGivenSessionAsSubscribedUseCase: SetGivenSessionAsSubscribedUseCase,
    private val walletConnectSessionSubscriptionBodyMapper: WalletConnectSessionSubscriptionBodyMapper
) {

    suspend operator fun invoke(walletConnectSession: WalletConnectSession, handshakeTopic: String) {
        firebasePushTokenUseCase.getPushTokenCacheFlow()
            .filter { it is CacheResult.Success }
            .collectLatest {
                mobileAlgorandApi.subscribeWalletConnectSession(
                    body = createWalletConnectSubscriptionRequestBody(
                        bridge = walletConnectSession.sessionMeta.bridge,
                        topic = handshakeTopic,
                        peerName = walletConnectSession.peerMeta.name,
                        pushToken = it?.data.orEmpty()
                    )
                ).also { setGivenSessionAsSubscribedUseCase.invoke(walletConnectSession.id) }
            }
    }

    private suspend fun createWalletConnectSubscriptionRequestBody(
        bridge: String,
        topic: String,
        peerName: String,
        pushToken: String
    ): WalletConnectSessionSubscriptionBody {
        return walletConnectSessionSubscriptionBodyMapper.mapToWalletConnectSessionSubscriptionBody(
            deviceId = deviceIdUseCase.getSelectedNodeDeviceId().orEmpty(),
            bridge = bridge,
            topic = topic,
            peerName = peerName,
            pushToken = pushToken
        )
    }
}
