package com.algorand.android.notification.data.di

import com.algorand.android.notification.data.local.AskNotificationPermissionEventSingleLocalCache
import com.algorand.android.notification.data.repository.NotificationPermissionRepositoryImpl
import com.algorand.android.notification.domain.repository.NotificationPermissionRepository
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named

@Module
@InstallIn(SingletonComponent::class)
class NotificationPermissionModule {

    @Named(NotificationPermissionRepository.INJECTION_NAME)
    @Provides
    fun provideNotificationPermissionRepository(
        askNotificationPermissionEventSingleLocalCache: AskNotificationPermissionEventSingleLocalCache
    ): NotificationPermissionRepository {
        return NotificationPermissionRepositoryImpl(
            askNotificationPermissionEventSingleLocalCache = askNotificationPermissionEventSingleLocalCache
        )
    }
}
