package com.algorand.android.modules.notification.data.repository

import com.algorand.android.modules.notification.domain.model.LastSeenNotificationDTO
import com.algorand.android.modules.notification.domain.repository.NotificationStatusRepository
import com.algorand.android.modules.notification.data.local.LastSeenNotificationIdLocalSource
import com.algorand.android.modules.notification.data.mapper.LastSeenNotificationDTOMapper
import com.algorand.android.modules.notification.data.mapper.LastSeenNotificationRequestMapper
import com.algorand.android.modules.notification.data.mapper.NotificationStatusDTOMapper
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

// TODO: Move to notification module
class NotificationStatusRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val lastSeenNotificationRequestMapper: LastSeenNotificationRequestMapper,
    private val notificationStatusDTOMapper: NotificationStatusDTOMapper,
    private val lastSeenNotificationDTOMapper: LastSeenNotificationDTOMapper,
    private val lastSeenNotificationIdLocalSource: LastSeenNotificationIdLocalSource,
) : NotificationStatusRepository {

    override suspend fun getNotificationStatus(deviceId: String) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getNotificationStatus(deviceId = deviceId)
    }.map { notificationStatusResponse ->
        notificationStatusDTOMapper.mapToNotificationStatusDTO(
            hasNewNotification = notificationStatusResponse.hasNewNotification
        )
    }

    override suspend fun putLastSeenNotificationId(
        deviceId: String,
        lastSeenNotificationDTO: LastSeenNotificationDTO
    ) = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        val lastSeenNotificationRequest = lastSeenNotificationRequestMapper.mapToLastSeenNotificationRequest(
            notificationId = lastSeenNotificationDTO.notificationId
        )
        mobileAlgorandApi.putLastSeenNotification(
            deviceId = deviceId,
            lastSeenRequest = lastSeenNotificationRequest
        )
    }.map { lastSeenNotificationResponse ->
        lastSeenNotificationDTOMapper.mapToLastSeenNotificationDTO(
            notificationId = lastSeenNotificationResponse.lastSeenNotificationId
        )
    }

    override suspend fun cacheLastSeenNotificationId(notificationId: Long) {
        lastSeenNotificationIdLocalSource.saveData(data = notificationId)
    }

    override suspend fun getCachedLastSeenNotificationId(): Long? {
        return lastSeenNotificationIdLocalSource.getDataOrNull()
    }
}
