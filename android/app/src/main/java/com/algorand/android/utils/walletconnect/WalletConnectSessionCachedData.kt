/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils.walletconnect

import android.util.Log
import org.walletconnect.Session
import org.walletconnect.Session.Config
import org.walletconnect.impls.WCSession

class WalletConnectSessionCachedData(
    var sessionId: Long,
    val session: WCSession,
    val sessionConfig: Config
) : Session.Callback {

    val approvedAccount: String
        get() = session.approvedAccounts()?.firstOrNull().orEmpty()

    private var callback: Callback? = null

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
        Log.e("test", "call -> $call")
        when (call) {
            is Session.MethodCall.SessionRequest -> callback?.onSessionRequest(sessionId, call.id, call)
            is Session.MethodCall.SessionUpdate -> callback?.onSessionUpdate(sessionId, call)
            is Session.MethodCall.Custom -> callback?.onCustomRequest(sessionId, call)
        }
    }

    override fun onStatus(status: Session.Status) {
        Log.e("test", "status -> $status")
        when (status) {
            Session.Status.Connected -> callback?.onSessionConnected(sessionId)
            Session.Status.Disconnected -> callback?.onSessionDisconnected(sessionId)
            Session.Status.Approved -> callback?.onSessionApproved(sessionId)
            is Session.Status.Error -> callback?.onSessionError(sessionId, status)
        }
    }

    companion object {
        fun create(session: WCSession, sessionConfig: Config, sessionId: Long? = null): WalletConnectSessionCachedData {
            val id = sessionId ?: System.currentTimeMillis()
            return WalletConnectSessionCachedData(id, session, sessionConfig)
        }
    }

    interface Callback {
        fun onSessionRequest(sessionId: Long, requestId: Long, call: Session.MethodCall.SessionRequest)
        fun onSessionUpdate(sessionId: Long, call: Session.MethodCall.SessionUpdate)
        fun onCustomRequest(sessionId: Long, call: Session.MethodCall.Custom)

        fun onSessionConnected(sessionId: Long)
        fun onSessionDisconnected(sessionId: Long)
        fun onSessionApproved(sessionId: Long)
        fun onSessionError(sessionId: Long, error: Session.Status.Error)
    }
}
