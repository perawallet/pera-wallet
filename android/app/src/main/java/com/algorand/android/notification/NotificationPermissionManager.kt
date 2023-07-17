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

package com.algorand.android.notification

import android.Manifest.permission.POST_NOTIFICATIONS
import android.content.Context
import android.os.Build
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.algorand.android.models.Account
import com.algorand.android.notification.domain.usecase.CacheAskNotificationPermissionEventUseCase
import com.algorand.android.notification.domain.usecase.GetAskNotificationPermissionEventFlowUseCase
import com.algorand.android.usecase.GetLocalAccountsUseCase
import com.algorand.android.utils.isPermissionGranted
import com.algorand.android.utils.launchIO
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest

@Singleton
class NotificationPermissionManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val getLocalAccountsUseCase: GetLocalAccountsUseCase,
    private val cacheAskNotificationPermissionEventUseCase: CacheAskNotificationPermissionEventUseCase,
    private val getAskNotificationPermissionEventFlowUseCase: GetAskNotificationPermissionEventFlowUseCase
) : DefaultLifecycleObserver {

    private var coroutineScope: CoroutineScope? = null

    private val localAccountCollector: suspend (value: List<Account>) -> Unit = {
        cacheAskNotificationPermissionIfPossible()
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        coroutineScope = CoroutineScope(Job() + Dispatchers.IO)
        initObservers()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        cancelJob()
    }

    private fun initObservers() {
        coroutineScope?.launchIO {
            getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCacheAsFlow().collectLatest(localAccountCollector)
        }
    }

    private fun cacheAskNotificationPermissionIfPossible() {
        if (isAskPermissionEventCachedBefore()) {
            cancelJob()
            return
        }
        if (!isBuildVersionValid()) return
        if (context.isPermissionGranted(POST_NOTIFICATIONS)) return

        if (canAskPermission()) {
            coroutineScope?.launchIO {
                cacheAskNotificationPermissionEventUseCase.invoke()
            }
        }
    }

    private fun canAskPermission(): Boolean {
        val localAccountCount = getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache().size
        return localAccountCount >= MIN_ACCOUNT_COUNT_TO_ASK_NOTIFICATION_PERMISSION
    }

    private fun isBuildVersionValid(): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU
    }

    private fun isAskPermissionEventCachedBefore(): Boolean {
        return getAskNotificationPermissionEventFlowUseCase.invoke().value != null
    }

    private fun cancelJob() {
        coroutineScope?.cancel()
        coroutineScope = null
    }

    companion object {
        private const val MIN_ACCOUNT_COUNT_TO_ASK_NOTIFICATION_PERMISSION = 1
    }
}
