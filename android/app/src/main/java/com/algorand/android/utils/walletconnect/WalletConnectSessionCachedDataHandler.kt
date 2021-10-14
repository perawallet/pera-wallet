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

import javax.inject.Inject

class WalletConnectSessionCachedDataHandler @Inject constructor() {

    private val connectedSessions: MutableList<WalletConnectSessionCachedData> = mutableListOf()

    fun getSessionById(id: Long) = getCachedDataById(id)?.session

    fun getCachedDataById(id: Long) = getConnectedSessions { sessions -> sessions.firstOrNull { it.sessionId == id } }

    fun isSessionCached(topic: String): Boolean {
        return getConnectedSessions { sessions -> sessions.any { it.sessionConfig.handshakeTopic == topic } }
    }

    fun addNewCachedData(sessionCachedData: WalletConnectSessionCachedData) {
        getConnectedSessions { sessions -> sessions.add(sessionCachedData) }
    }

    fun deleteCachedData(sessionId: Long, onCacheDeleted: (WalletConnectSessionCachedData) -> Unit) {
        val sessionIndex = getConnectedSessions { sessions -> sessions.indexOfFirst { it.sessionId == sessionId } }
        if (sessionIndex != -1) {
            getConnectedSessions { it.removeAt(sessionIndex).also { onCacheDeleted(it) } }
        }
    }

    private fun <T> getConnectedSessions(action: (MutableList<WalletConnectSessionCachedData>) -> T): T {
        return synchronized(this) {
            action(connectedSessions)
        }
    }
}
