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

import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectSessionCachedData.Companion.INITIAL_RETRY_COUNT
import com.algorand.android.utils.popIfOrNull
import javax.inject.Inject

class WalletConnectSessionCachedDataHandler @Inject constructor() {

    private val connectedSessions: MutableList<WalletConnectSessionCachedData> = mutableListOf()

    fun getSessionById(id: Long) = getCachedDataById(id)?.session

    fun getCachedDataById(id: Long) = getConnectedSessions { sessions -> sessions.firstOrNull { it.sessionId == id } }

    fun addNewCachedData(sessionCachedData: WalletConnectSessionCachedData) {
        getConnectedSessions { sessions ->
            val cachedSession = sessions.popIfOrNull { it.sessionId == sessionCachedData.sessionId }
            val safeRetryCount = cachedSession?.retryCount ?: INITIAL_RETRY_COUNT
            sessionCachedData.retryCount = safeRetryCount
            sessions.add(sessionCachedData)
        }
    }

    fun deleteCachedData(sessionId: Long, onCacheDeleted: (WalletConnectSessionCachedData) -> Unit) {
        getConnectedSessions { sessions ->
            val sessionIndex = sessions.indexOfFirst { it.sessionId == sessionId }
            if (sessionIndex != ITEM_NOT_FOUND_INDEX) {
                sessions.removeAt(sessionIndex).also { onCacheDeleted(it) }
            }
        }
    }

    // TODO Use Mutex
    private fun <T> getConnectedSessions(action: (MutableList<WalletConnectSessionCachedData>) -> T): T {
        return synchronized(this) {
            action(connectedSessions)
        }
    }

    companion object {
        private const val ITEM_NOT_FOUND_INDEX = -1
    }
}
