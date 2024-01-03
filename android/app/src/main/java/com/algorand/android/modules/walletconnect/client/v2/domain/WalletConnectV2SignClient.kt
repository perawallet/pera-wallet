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

package com.algorand.android.modules.walletconnect.client.v2.domain

import android.util.Log
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.utils.launchIO
import com.walletconnect.sign.client.Sign
import com.walletconnect.sign.client.SignClient
import com.walletconnect.sign.common.exceptions.CannotFindSequenceForTopic
import javax.inject.Inject
import javax.inject.Named
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

@Singleton
class WalletConnectV2SignClient @Inject constructor(
    @Named(WalletConnectV2Repository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectV2Repository
) {

    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    fun setWalletDelegate(delegate: SignClient.WalletDelegate) {
        SignClient.setWalletDelegate(delegate)
    }

    fun initialize(initParams: Sign.Params.Init) {
        SignClient.initialize(initParams) { error ->
            logError(error)
        }
    }

    fun approveSession(approveProposal: Sign.Params.Approve) {
        SignClient.approveSession(approveProposal) { error ->
            logError(error)
        }
    }

    fun rejectSession(reject: Sign.Params.Reject) {
        SignClient.rejectSession(reject) { error ->
            logError(error)
        }
    }

    fun respond(response: Sign.Params.Response) {
        SignClient.respond(response) { error ->
            onSignClientError(response.sessionTopic, error)
        }
    }

    fun disconnect(disconnect: Sign.Params.Disconnect) {
        SignClient.disconnect(disconnect) { error ->
            onSignClientError(disconnect.sessionTopic, error)
        }
    }

    fun update(update: Sign.Params.Update) {
        SignClient.update(update) { error ->
            onSignClientError(update.sessionTopic, error)
        }
    }

    fun extend(extend: Sign.Params.Extend, onSuccess: (String) -> Unit, onError: (Throwable) -> Unit) {
        SignClient.extend(
            extend = extend,
            onSuccess = { extendParams -> onSuccess(extendParams.topic) },
            onError = { error -> onError(error.throwable) }
        )
    }

    fun pingServer(ping: Sign.Params.Ping, onSuccess: (String) -> Unit, onError: (Throwable) -> Unit) {
        val listener = object : Sign.Listeners.SessionPing {
            override fun onError(pingError: Sign.Model.Ping.Error) {
                onError(pingError.error)
            }

            override fun onSuccess(pingSuccess: Sign.Model.Ping.Success) {
                onSuccess(pingSuccess.topic)
            }
        }
        SignClient.ping(
            ping = ping,
            sessionPing = listener
        )
    }

    fun getActiveSessionByTopic(topic: String): Sign.Model.Session? {
        return SignClient.getActiveSessionByTopic(topic)
    }

    fun getListOfActiveSessions(): List<Sign.Model.Session> {
        return SignClient.getListOfActiveSessions()
    }

    private fun onSignClientError(sessionTopic: String, error: Sign.Model.Error) {
        logError(error)
        if (error.throwable is CannotFindSequenceForTopic) {
            coroutineScope.launchIO {
                walletConnectRepository.deleteById(sessionTopic)
            }
        }
    }

    private fun logError(error: Sign.Model.Error) {
        logError("${error.throwable} - ${error.throwable.stackTraceToString()}")
    }

    private fun logError(message: String) {
        Log.e(logTag, message)
    }

    companion object {
        private val logTag = SignClient::class.simpleName
    }
}
