package com.algorand.android.modules.notification.di

import com.algorand.android.modules.notification.domain.repository.NotificationStatusRepository
import com.algorand.android.modules.notification.data.local.LastSeenNotificationIdLocalSource
import com.algorand.android.modules.notification.data.mapper.LastSeenNotificationDTOMapper
import com.algorand.android.modules.notification.data.mapper.LastSeenNotificationRequestMapper
import com.algorand.android.modules.notification.data.mapper.NotificationStatusDTOMapper
import com.algorand.android.modules.notification.data.repository.NotificationStatusRepositoryImpl
import com.algorand.android.network.MobileAlgorandApi
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NotificationStatusRepositoryModule {

    @Provides
    @Singleton
    @Named(NotificationStatusRepository.REPOSITORY_INJECTION_NAME)
    internal fun provideNotificationStatusRepository(
        mobileAlgorandApi: MobileAlgorandApi,
        hipoErrorHandler: RetrofitErrorHandler,
        lastSeenNotificationRequestMapper: LastSeenNotificationRequestMapper,
        notificationStatusDTOMapper: NotificationStatusDTOMapper,
        lastSeenNotificationDTOMapper: LastSeenNotificationDTOMapper,
        lastSeenNotificationIdLocalSource: LastSeenNotificationIdLocalSource
    ): NotificationStatusRepository {
        return NotificationStatusRepositoryImpl(
            mobileAlgorandApi = mobileAlgorandApi,
            hipoApiErrorHandler = hipoErrorHandler,
            lastSeenNotificationRequestMapper = lastSeenNotificationRequestMapper,
            notificationStatusDTOMapper = notificationStatusDTOMapper,
            lastSeenNotificationDTOMapper = lastSeenNotificationDTOMapper,
            lastSeenNotificationIdLocalSource = lastSeenNotificationIdLocalSource
        )
    }
}
