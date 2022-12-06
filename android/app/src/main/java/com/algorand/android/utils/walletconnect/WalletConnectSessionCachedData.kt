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

package com.algorand.android.utils.walletconnect

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

    private var retryCount: Int = INITIAL_RETRY_COUNT

    init {
        session.addCallback(this)
    }

    fun setRetryCount(count: Int) {
        synchronized(this) {
            retryCount = count
        }
    }

    fun getRetryCount(): Int {
        synchronized(this) {
            return retryCount
        }
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
            is Session.MethodCall.SessionRequest -> callback?.onSessionRequest(sessionId, call.id, call, call.chainId)
            is Session.MethodCall.SessionUpdate -> callback?.onSessionUpdate(sessionId, call)
            is Session.MethodCall.Custom -> callback?.onCustomRequest(sessionId, call)
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectSessionCachedData")
            }
        }
    }

    override fun onStatus(status: Session.Status) {
        Log.e(logTag, "onStatus -> $status")
        when (status) {
            Session.Status.Connected -> callback?.onSessionConnected(sessionId)
            is Session.Status.Disconnected -> callback?.onSessionDisconnected(sessionId, status.isSessionDeletionNeeded)
            Session.Status.Approved -> callback?.onSessionApproved(sessionId)
            is Session.Status.Error -> callback?.onSessionError(sessionId, status)
            else -> {
                sendErrorLog("Unhandled else case in WalletConnectSessionCachedData")
            }
        }
    }

    companion object {

        private val logTag = WalletConnectSessionCachedData::class.java.simpleName

        const val INITIAL_RETRY_COUNT = 0

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
        fun onSessionRequest(sessionId: Long, requestId: Long, call: Session.MethodCall.SessionRequest, chainId: Long?)
        fun onSessionUpdate(sessionId: Long, call: Session.MethodCall.SessionUpdate)
        fun onCustomRequest(sessionId: Long, call: Session.MethodCall.Custom)

        fun onSessionConnected(sessionId: Long)
        fun onSessionDisconnected(sessionId: Long, isSessionDeletionNeeded: Boolean)
        fun onSessionApproved(sessionId: Long)
        fun onSessionError(sessionId: Long, error: Session.Status.Error)
    }
}
