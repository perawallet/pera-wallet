package com.algorand.android.modules.notification.domain.pagination

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.modules.notification.data.model.NotificationResponse
import com.algorand.android.modules.notification.ui.model.NotificationListItem
import com.algorand.android.modules.notification.ui.utils.NotificationIconDrawableProvider
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.PeraPagingSource
import com.algorand.android.utils.exceptions.MissingNotificationUserIdException
import com.algorand.android.utils.getAlgorandMobileDateFormatter
import com.algorand.android.utils.parseFormattedDate
import com.algorand.android.utils.recordException
import java.time.ZonedDateTime

class NotificationDataSource(
    private val notificationRepository: NotificationRepository,
    private val deviceIdUseCase: DeviceIdUseCase
) : PeraPagingSource<String, NotificationListItem>() {

    override val logTag: String = NotificationDataSource::class.java.simpleName

    private var notificationUserId: String? = null

    override suspend fun initializeData(): LoadResult<String, NotificationListItem> {
        val notificationUserId = getNotificationUserId()
        return if (notificationUserId.isNullOrBlank()) {
            val exception = MissingNotificationUserIdException()
            recordException(exception)
            LoadResult.Error(exception)
        } else {
            val result = notificationRepository.getNotifications(notificationUserId)
            parseResult(result)
        }
    }

    override suspend fun loadMore(loadUrl: String): LoadResult<String, NotificationListItem> {
        val result = notificationRepository.getNotificationsMore(loadUrl)
        return parseResult(result)
    }

    private fun parseResult(
        result: Result<Pagination<NotificationResponse>>,
    ): LoadResult<String, NotificationListItem> {
        return when (result) {
            is Result.Success -> {
                val notificationListItems = result.data.results.toListItems()
                val nextKey = result.data.next
                LoadResult.Page(data = notificationListItems, prevKey = null, nextKey = nextKey)
            }
            is Result.Error -> {
                LoadResult.Error(result.exception)
            }
        }
    }

    private suspend fun getNotificationUserId(): String? {
        return notificationUserId ?: (
            deviceIdUseCase.getSelectedNodeDeviceId()?.also { newNotificationUserId ->
                notificationUserId = newNotificationUserId
            }
            )
    }

    private fun List<NotificationResponse>.toListItems(): List<NotificationListItem> {
        val now = ZonedDateTime.now()
        val nowInTimeMillis = now.toInstant().toEpochMilli()
        val dateFormatter = getAlgorandMobileDateFormatter()
        return mapNotNull { notificationItem ->
            val creationZonedDateTime = notificationItem.creationDatetime.parseFormattedDate(dateFormatter) ?: now

            val timeDifference = nowInTimeMillis - creationZonedDateTime.toInstant().toEpochMilli()
            // If the ID is missing or null, we shouldn't take the notification
            notificationItem.id?.let { notificationId ->
                val isFailed = notificationItem.url?.isBlank() ?: true
                NotificationListItem(
                    id = notificationId,
                    uri = notificationItem.url,
                    isFailed = isFailed,
                    creationDateTime = creationZonedDateTime,
                    timeDifference = timeDifference,
                    message = notificationItem.message ?: "",
                    notificationIconDrawableProvider = NotificationIconDrawableProvider.create(
                        isFailed = isFailed,
                        logoUri = notificationItem.icon?.prismUrl
                    )
                )
            }
        }
    }
}
