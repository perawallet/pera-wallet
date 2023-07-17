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

package com.algorand.android.modules.walletconnect.client.v2.serverstatus

import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectClientV2Mapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class WalletConnectV2SessionServerStatusManagerImpl(
    private val signClient: WalletConnectV2SignClient,
    private val clientV2Mapper: WalletConnectClientV2Mapper
) : WalletConnectV2SessionServerStatusManager {

    override suspend fun checkStatus(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): Result<Unit> = suspendCoroutine { continuous ->
        val ping = clientV2Mapper.mapToPing(sessionIdentifier.getIdentifier())
        signClient.pingServer(
            ping = ping,
            onSuccess = { continuous.resume(Result.success(Unit)) },
            onError = { throwable -> continuous.resume(Result.failure(throwable)) }
        )
    }
}
