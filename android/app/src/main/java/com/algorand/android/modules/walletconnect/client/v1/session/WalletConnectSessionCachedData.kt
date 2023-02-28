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

package com.algorand.android.modules.walletconnect.client.v1.session

import android.util.Log
import com.algorand.android.utils.sendErrorLog
import org.walletconnect.Session
import org.walletconnect.Session.Config
import org.walletconnect.impls.WCSession

class WalletConnectSessionCachedData(
    var sessionId: Long,
    val session: WCSession,
    val sessionConfig: Config,
    val fallbackBrowserGroupResponse: String?
) : Session.Callback {

    val approvedAccounts: List<String>
        get() = session.approvedAccounts().orEmpty()

    private var callback: Callback? = null

    var retryCount: Int = INITIAL_RETRY_COUNT
        get() = field.coerceAtMost(MAX_SESSION_RETRY_COUNT)

    init {
        session.addCallback(this)
    }

    fun addCallback(callback: Callback) {
        this.callback = callback
    }

    fun removeCallback() {
        callback = null
    }

    override fun onMethodCall(call: Session.MethodCall) {
        Log.e(logTag, "onMethodCall -> $call")
        when (call) {
            is Session.MethodCall.SessionRequest -> callback?.onSessionRequest(this, call.id, call, call.chainId)
            is Session.MethodCall.SessionUpdate -> callback?.onSessionUpdate(this, call)
            is Session.MethodCall.Custom -> callback?.onCustomRequest(this, call)
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectSessionCachedData")
            }
        }
    }

    override fun onStatus(status: Session.Status) {
        Log.e(logTag, "onStatus -> $status")
        when (status) {
            is Session.Status.Connected -> callback?.onSessionConnected(this, status.clientId)
            is Session.Status.Disconnected -> callback?.onSessionDisconnected(this, status.isSessionDeletionNeeded)
            is Session.Status.Approved -> callback?.onSessionApproved(this, status.clientId)
            is Session.Status.Error -> callback?.onSessionError(this, status)
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectSessionCachedData")
            }
        }
    }

    companion object {

        private val logTag = WalletConnectSessionCachedData::class.java.simpleName

        const val INITIAL_RETRY_COUNT = 1
        private const val MAX_SESSION_RETRY_COUNT = 10

        fun create(
            session: WCSession,
            sessionConfig: Config,
            sessionId: Long? = null,
            fallbackBrowserGroupResponse: String? = null
        ): WalletConnectSessionCachedData {
            val id = sessionId ?: System.currentTimeMillis()
            return WalletConnectSessionCachedData(id, session, sessionConfig, fallbackBrowserGroupResponse)
        }
    }

    interface Callback {
        fun onSessionRequest(
            cachedData: WalletConnectSessionCachedData,
            requestId: Long,
            call: Session.MethodCall.SessionRequest,
            chainId: Long?
        )

        fun onSessionUpdate(cachedData: WalletConnectSessionCachedData, call: Session.MethodCall.SessionUpdate)
        fun onCustomRequest(cachedData: WalletConnectSessionCachedData, call: Session.MethodCall.Custom)

        fun onSessionConnected(cachedData: WalletConnectSessionCachedData, clientId: String)
        fun onSessionDisconnected(cachedData: WalletConnectSessionCachedData, isDeletionNeeded: Boolean)
        fun onSessionApproved(cachedData: WalletConnectSessionCachedData, clientId: String)
        fun onSessionError(cachedData: WalletConnectSessionCachedData, error: Session.Status.Error)
        fun onSessionKilled(cachedData: WalletConnectSessionCachedData)
    }
}
