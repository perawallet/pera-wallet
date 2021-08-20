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

import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSessionMeta
import com.algorand.android.models.WalletConnectTransactionErrorResponse
import org.walletconnect.Session
import org.walletconnect.Session.MethodCall.Custom
import org.walletconnect.Session.MethodCall.SessionRequest
import org.walletconnect.Session.MethodCall.SessionUpdate
import org.walletconnect.impls.WCSession

class WCWalletConnectClient(
    private val sessionBuilder: WalletConnectSessionBuilder,
    private val walletConnectMapper: WCWalletConnectMapper
) : WalletConnectClient {

    private var listener: WalletConnectClientListener? = null

    private val connectedSessions: MutableList<WalletConnectSessionCachedData> = mutableListOf()

    private val sessionCacheDataCallback = object : WalletConnectSessionCachedData.Callback {
        override fun onSessionRequest(sessionId: Long, requestId: Long, call: SessionRequest) {
            listener?.onSessionRequest(sessionId, requestId, getWalletConnectSession(sessionId) ?: return)
        }

        override fun onSessionUpdate(sessionId: Long, call: SessionUpdate) {
            if (!call.params.approved) {
                listener?.onSessionKilled(sessionId)
            }
        }

        override fun onCustomRequest(sessionId: Long, call: Custom) {
            listener?.onCustomRequest(sessionId, call.id, call.params ?: return)
        }

        override fun onSessionConnected(sessionId: Long) {
            listener?.onConnected(sessionId, getWalletConnectSession(sessionId))
        }

        override fun onSessionDisconnected(sessionId: Long) {
            deleteSessionById(sessionId)
            listener?.onDisconnected(sessionId)
        }

        override fun onSessionApproved(sessionId: Long) {
            val walletConnectSession = getWalletConnectSession(sessionId) ?: return
            listener?.onSessionApproved(sessionId, walletConnectSession)
        }

        override fun onSessionError(sessionId: Long, error: Session.Status.Error) {
            listener?.onFailure(sessionId, error)
        }
    }

    override fun connect(uri: String) {
        val session = sessionBuilder.createSession(uri) ?: return
        connectToSession(session)
    }

    override fun connect(sessionId: Long, sessionMeta: WalletConnectSessionMeta) {
        if (isSessionCached(sessionMeta.topic)) return
        val session = sessionBuilder.createSession(sessionId, sessionMeta) ?: return
        connectToSession(session)
    }

    override fun setListener(listener: WalletConnectClientListener) {
        this.listener = listener
    }

    override fun approveSession(id: Long, accountAddress: String) {
        getSessionById(id)?.approve(listOf(accountAddress), ALGO_CHAIN_ID)
    }

    override fun rejectSession(id: Long) {
        getSessionById(id)?.reject()
        deleteSessionById(id)
    }

    override fun killSession(id: Long) {
        getSessionById(id)?.kill()
        deleteSessionById(id)
        listener?.onSessionKilled(id)
    }

    override fun disconnectFromSession(id: Long) {
        listener?.onDisconnected(id)
        deleteSessionById(id)
    }

    override fun rejectRequest(sessionId: Long, requestId: Long, errorResponse: WalletConnectTransactionErrorResponse) {
        getSessionById(sessionId)?.rejectRequest(requestId, errorResponse.responseCode, errorResponse.message)
    }

    override fun approveRequest(sessionId: Long, requestId: Long, payload: Any) {
        getSessionById(sessionId)?.approveRequest(requestId, payload)
    }

    private fun connectToSession(sessionCacheData: WalletConnectSessionCachedData) {
        with(sessionCacheData) {
            addCallback(sessionCacheDataCallback)
            session.offer()
        }
        connectedSessions.add(sessionCacheData)
    }

    override fun getWalletConnectSession(sessionId: Long): WalletConnectSession? {
        val sessionCacheData = getCachedDataById(sessionId) ?: return null
        return walletConnectMapper.createWalletConnectSession(sessionCacheData)
    }

    private fun getSessionById(id: Long): WCSession? {
        return connectedSessions.firstOrNull { it.sessionId == id }?.session
    }

    private fun getCachedDataById(id: Long): WalletConnectSessionCachedData? {
        return connectedSessions.firstOrNull { it.sessionId == id }
    }

    private fun deleteSessionById(id: Long) {
        val sessionIndex = connectedSessions.indexOfFirst { it.sessionId == id }
        if (sessionIndex != -1) {
            connectedSessions.removeAt(sessionIndex).also {
                it.removeCallback()
            }
        }
    }

    private fun isSessionCached(topic: String): Boolean {
        return connectedSessions.any { it.sessionConfig.handshakeTopic == topic }
    }

    companion object {
        const val CACHE_STORAGE_NAME = "session_store.json"
    }
}
