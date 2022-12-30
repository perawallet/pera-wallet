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

import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSessionMeta
import com.algorand.android.models.WalletConnectTransactionErrorResponse
import com.algorand.android.utils.exception.InvalidWalletConnectUrlException
import com.algorand.android.utils.walletconnect.WalletConnectSessionCachedData.Companion.INITIAL_RETRY_COUNT
import org.walletconnect.Session
import org.walletconnect.Session.MethodCall.Custom
import org.walletconnect.Session.MethodCall.SessionRequest
import org.walletconnect.Session.MethodCall.SessionUpdate
import org.walletconnect.impls.WCSession

class WCWalletConnectClient(
    private val sessionBuilder: WalletConnectSessionBuilder,
    private val walletConnectMapper: WCWalletConnectMapper,
    private val sessionCachedDataHandler: WalletConnectSessionCachedDataHandler
) : WalletConnectClient {

    private var listener: WalletConnectClientListener? = null

    private val sessionCacheDataCallback = object : WalletConnectSessionCachedData.Callback {
        override fun onSessionRequest(sessionId: Long, requestId: Long, call: SessionRequest, chainId: Long?) {
            listener?.onSessionRequest(
                sessionId = sessionId,
                requestId = requestId,
                session = getWalletConnectSession(sessionId) ?: return,
                chainId = chainId
            )
        }

        override fun onSessionUpdate(sessionId: Long, call: SessionUpdate) {
            listener?.onSessionUpdate(sessionId, call.params.accounts, call.params.chainId)
            if (!call.params.approved) {
                listener?.onSessionKilled(sessionId)
            }
        }

        override fun onCustomRequest(sessionId: Long, call: Custom) {
            listener?.onCustomRequest(sessionId, call.id, call.params ?: return)
        }

        override fun onSessionConnected(sessionId: Long, clientId: String) {
            listener?.onConnected(sessionId, getWalletConnectSession(sessionId), clientId)
        }

        override fun onSessionDisconnected(sessionId: Long, isSessionDeletionNeeded: Boolean) {
            if (isSessionDeletionNeeded) {
                deleteSessionById(sessionId)
            }
            listener?.onDisconnected(sessionId)
        }

        override fun onSessionApproved(sessionId: Long, clientId: String) {
            val walletConnectSession = getWalletConnectSession(sessionId) ?: return
            listener?.onSessionApproved(sessionId, walletConnectSession, clientId)
        }

        override fun onSessionError(sessionId: Long, error: Session.Status.Error) {
            listener?.onFailure(sessionId, error)
        }
    }

    override fun connect(uri: String) {
        val session = sessionBuilder.createSession(uri) ?: run {
            listener?.onFailure(-1, Session.Status.Error(InvalidWalletConnectUrlException))
            return
        }
        connectToSession(session)
    }

    override fun connect(
        sessionId: Long,
        sessionMeta: WalletConnectSessionMeta,
        fallbackBrowserGroupResponse: String?
    ) {
        val session = sessionBuilder.createSession(sessionId, sessionMeta, fallbackBrowserGroupResponse) ?: return
        connectToSession(session)
    }

    override fun setListener(listener: WalletConnectClientListener) {
        this.listener = listener
    }

    override fun approveSession(id: Long, accountAddresses: List<String>, chainId: Long?) {
        getSessionById(id)?.approve(accountAddresses, chainId ?: DEFAULT_CHAIN_ID)
    }

    override fun updateSession(id: Long, accountAddresses: List<String>?, chainId: Long?) {
        getSessionById(id)?.update(accountAddresses.orEmpty(), chainId ?: DEFAULT_CHAIN_ID)
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
        sessionCachedDataHandler.addNewCachedData(sessionCacheData)
    }

    override fun getWalletConnectSession(sessionId: Long): WalletConnectSession? {
        val sessionCacheData = sessionCachedDataHandler.getCachedDataById(sessionId) ?: return null
        return walletConnectMapper.createWalletConnectSession(sessionCacheData)
    }

    override fun getSessionRetryCount(sessionId: Long): Int {
        val sessionCacheData = sessionCachedDataHandler.getCachedDataById(sessionId)
        return sessionCacheData?.getRetryCount() ?: INITIAL_RETRY_COUNT
    }

    override fun setSessionRetryCount(sessionId: Long, retryCount: Int) {
        val sessionCacheData = sessionCachedDataHandler.getCachedDataById(sessionId) ?: return
        sessionCacheData.setRetryCount(retryCount)
    }

    override fun clearSessionRetryCount(sessionId: Long) {
        setSessionRetryCount(sessionId, INITIAL_RETRY_COUNT)
    }

    private fun getSessionById(id: Long): WCSession? {
        return sessionCachedDataHandler.getSessionById(id)
    }

    private fun deleteSessionById(id: Long) {
        sessionCachedDataHandler.deleteCachedData(id) { it.removeCallback() }
    }

    companion object {
        const val CACHE_STORAGE_NAME = "session_store.json"
    }
}
