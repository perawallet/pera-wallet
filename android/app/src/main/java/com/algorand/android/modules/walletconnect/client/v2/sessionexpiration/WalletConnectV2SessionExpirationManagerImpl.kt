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

package com.algorand.android.modules.walletconnect.client.v2.sessionexpiration

import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectClientV2Mapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.utils.getCurrentTimeAsSec
import com.walletconnect.android.Core
import com.walletconnect.android.CoreClient
import javax.inject.Inject
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class WalletConnectV2SessionExpirationManagerImpl @Inject constructor(
    private val signClient: WalletConnectV2SignClient,
    private val clientV2Mapper: WalletConnectClientV2Mapper
) : WalletConnectV2SessionExpirationManager {

    override suspend fun extendSessionExpirationDate(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): Result<String> = suspendCoroutine { continuation ->
        val sessionTopic = sessionIdentifier.getIdentifier()
        val extend = clientV2Mapper.mapToExtend(sessionTopic)
        signClient.extend(
            extend = extend,
            onSuccess = { topic -> continuation.resume(Result.success(topic)) },
            onError = { throwable -> continuation.resume(Result.failure(throwable)) }
        )
    }

    override suspend fun isSessionExtendable(sessionIdentifier: WalletConnect.SessionIdentifier): Boolean {
        val sessionDetail = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return false
        val sessionPair = getSessionPair(sessionDetail.pairingTopic) ?: return false
        return sessionDetail.expiry + DEFAULT_EXPIRATION_DATE_DELAY_TIME_AS_SECOND < sessionPair.expiry
    }

    override suspend fun hasSessionReachedMaxValidity(sessionIdentifier: WalletConnect.SessionIdentifier): Boolean {
        val sessionDetail = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return false
        val sessionPair = getSessionPair(sessionDetail.pairingTopic) ?: return false
        return getCurrentTimeAsSec() + DEFAULT_EXPIRATION_DATE_DELAY_TIME_AS_SECOND >= sessionPair.expiry
    }

    override suspend fun getSessionExpirationDateExtendedTimeStampAsSec(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): Long? {
        val sessionDetail = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return null
        return sessionDetail.expiry + DEFAULT_EXPIRATION_DATE_DELAY_TIME_AS_SECOND
    }

    override suspend fun getSessionExpirationDateTimeStampAsSec(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): Long? {
        val sessionDetail = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return null
        return sessionDetail.expiry
    }

    override suspend fun getMaxSessionExpirationDateTimeStampAsSec(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): Long? {
        val sessionDetail = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return null
        return getSessionPair(sessionDetail.pairingTopic)?.expiry
    }

    private fun getSessionPair(pairingTopic: String): Core.Model.Pairing? {
        return CoreClient.Pairing.getPairings().firstOrNull { it.topic == pairingTopic }
    }

    companion object {
        private const val DEFAULT_EXPIRATION_DATE_DELAY_TIME_AS_SECOND = 604_800
    }
}
