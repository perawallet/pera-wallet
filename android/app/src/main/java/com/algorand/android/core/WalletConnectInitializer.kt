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

package com.algorand.android.core

import android.app.Application
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.coroutineScope
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.WalletConnectSessionsStatusManager
import com.algorand.android.utils.launchIO
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class WalletConnectInitializer @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val walletConnectSessionsStatusManager: WalletConnectSessionsStatusManager
) {

    fun initialize(application: Application, lifecycle: Lifecycle) {
        lifecycle.coroutineScope.launchIO {
            walletConnectManager.initializeClients(application)
            withContext(Dispatchers.Main) {
                bindLifecycleAwareComponent(lifecycle)
                registerActivityLifecycleCallbacks(application)
            }
        }
    }

    private fun bindLifecycleAwareComponent(lifecycle: Lifecycle) {
        lifecycle.addObserver(walletConnectManager)
    }

    private fun registerActivityLifecycleCallbacks(application: Application) {
        application.registerActivityLifecycleCallbacks(walletConnectSessionsStatusManager)
    }
}
