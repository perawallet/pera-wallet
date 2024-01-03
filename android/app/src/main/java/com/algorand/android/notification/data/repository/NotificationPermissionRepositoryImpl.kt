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

package com.algorand.android.notification.data.repository

import com.algorand.android.notification.data.local.AskNotificationPermissionEventSingleLocalCache
import com.algorand.android.notification.domain.repository.NotificationPermissionRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.Event
import kotlinx.coroutines.flow.StateFlow

class NotificationPermissionRepositoryImpl constructor(
    private val askNotificationPermissionEventSingleLocalCache: AskNotificationPermissionEventSingleLocalCache
) : NotificationPermissionRepository {

    override suspend fun cacheAskNotificationPermissionEvent() {
        askNotificationPermissionEventSingleLocalCache.put(CacheResult.Success.create(Event(Unit)))
    }

    override fun getAskNotificationPermissionEventFlow(): StateFlow<CacheResult<Event<Unit>>?> {
        return askNotificationPermissionEventSingleLocalCache.cacheFlow
    }
}
