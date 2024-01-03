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

package com.algorand.android.modules.walletconnect.domain

import android.app.Activity
import com.algorand.android.MainActivity
import com.algorand.android.utils.ActivityLifecycleObserver
import com.algorand.android.utils.getCurrentSystemTimeAsMillis
import com.algorand.android.utils.launchIO
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import javax.inject.Inject

class WalletConnectSessionsStatusManager @Inject constructor(
    private val walletConnectManager: WalletConnectManager
) : ActivityLifecycleObserver {

    private var latestDisconnectingTimeStamp: Long? = null
    private var reconnectingCoroutineScope: CoroutineScope? = null

    override fun onActivityResumed(activity: Activity) {
        super.onActivityResumed(activity)
        if (activity !is MainActivity) return
        connectToDisconnectedSessions()
    }

    override fun onActivityStopped(activity: Activity) {
        super.onActivityStopped(activity)
        if (activity !is MainActivity) return
        disconnectExistingSessions()
    }

    private fun connectToDisconnectedSessions() {
        // Waiting for reconnecting is required due to disconnecting operations are not completed
        // when reconnected is called
        if (shouldWaitForReconnecting()) {
            initializeReconnectingCoroutineScope()
            reconnectingCoroutineScope?.launchIO {
                delay(CONNECT_SUSPENDING_DELAY_TIME)
                walletConnectManager.connectToDisconnectedSessions()
            }?.invokeOnCompletion {
                reconnectingCoroutineScope = null
            }
        } else {
            walletConnectManager.connectToDisconnectedSessions()
        }
    }

    private fun disconnectExistingSessions() {
        latestDisconnectingTimeStamp = getCurrentSystemTimeAsMillis()
        walletConnectManager.disconnectFromExistingSessions()
    }

    private fun shouldWaitForReconnecting(): Boolean {
        return latestDisconnectingTimeStamp?.let { disconnectingTimeStamp ->
            disconnectingTimeStamp + RECONNECTING_TIME_THRESHOLD > getCurrentSystemTimeAsMillis()
        } ?: false
    }

    private fun initializeReconnectingCoroutineScope() {
        reconnectingCoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    }

    companion object {
        private const val CONNECT_SUSPENDING_DELAY_TIME = 250L
        private const val RECONNECTING_TIME_THRESHOLD = 250L
    }
}
