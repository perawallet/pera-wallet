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

package com.algorand.android.modules.notification.ui

import androidx.lifecycle.LiveData
import androidx.lifecycle.map
import androidx.lifecycle.viewModelScope
import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.cachedIn
import com.algorand.android.core.BaseViewModel
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.modules.notification.domain.pagination.NotificationDataSource
import com.algorand.android.modules.notification.domain.usecase.NotificationStatusUseCase
import com.algorand.android.modules.notification.ui.model.NotificationCenterPreview
import com.algorand.android.modules.notification.ui.model.NotificationListItem
import com.algorand.android.modules.notification.ui.usecase.NotificationCenterPreviewUseCase
import com.algorand.android.notification.PeraNotificationManager
import com.algorand.android.repository.NotificationRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import java.time.ZonedDateTime
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.shareIn
import kotlinx.coroutines.launch

@HiltViewModel
class NotificationCenterViewModel @Inject constructor(
    private val peraNotificationManager: PeraNotificationManager,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val notificationRepository: NotificationRepository,
    private val notificationCenterPreviewUseCase: NotificationCenterPreviewUseCase,
    private val notificationStatusUseCase: NotificationStatusUseCase
) : BaseViewModel() {

    private var notificationDataSource: NotificationDataSource? = null

    val notificationPaginationFlow = Pager(
        config = PagingConfig(
            pageSize = DEFAULT_NOTIFICATION_COUNT
        ),
        pagingSourceFactory = {
            NotificationDataSource(
                notificationRepository = notificationRepository,
                deviceIdUseCase = deviceIdUseCase
            ).also { notificationDataSource = it }
        }
    ).flow
        .cachedIn(viewModelScope)
        .shareIn(viewModelScope, SharingStarted.Lazily)

    private val _notificationCenterPreviewFlow = MutableStateFlow<NotificationCenterPreview?>(null)
    val notificationCenterPreviewFlow: StateFlow<NotificationCenterPreview?> get() = _notificationCenterPreviewFlow

    fun refreshNotificationData(refreshDateTime: ZonedDateTime? = null) {
        if (refreshDateTime != null) {
            setLastRefreshedDateTime(refreshDateTime)
        }
        notificationDataSource?.invalidate()
    }

    fun getLastRefreshedDateTime(): ZonedDateTime {
        return notificationCenterPreviewUseCase.getLastRefreshedDateTime()
    }

    fun setLastRefreshedDateTime(zonedDateTime: ZonedDateTime) {
        notificationCenterPreviewUseCase.setLastRefreshedDateTime(zonedDateTime)
    }

    fun onNotificationClickEvent(notificationListItem: NotificationListItem) {
        viewModelScope.launch {
            notificationCenterPreviewUseCase.onNotificationClickEvent(notificationListItem).collect {
                _notificationCenterPreviewFlow.emit(it)
            }
        }
    }

    fun isRefreshNeededLiveData(): LiveData<Boolean> {
        var newNotificationCount = 0
        return peraNotificationManager.newNotificationLiveData.map {
            newNotificationCount++
            return@map newNotificationCount > 1
        }
    }

    fun updateLastSeenNotification(notificationListItem: NotificationListItem?) {
        viewModelScope.launch {
            notificationStatusUseCase.updateLastSeenNotificationId(
                notificationListItem = notificationListItem ?: return@launch
            )
        }
    }

    companion object {
        private const val DEFAULT_NOTIFICATION_COUNT = 15
    }
}
