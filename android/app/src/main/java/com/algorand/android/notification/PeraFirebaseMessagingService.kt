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

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import androidx.core.app.NotificationCompat
import com.algorand.android.R
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.notification.domain.model.NotificationMetadata
import com.algorand.android.notification.domain.model.NotificationWCData
import com.algorand.android.ui.splash.LauncherActivity
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.decodeBase64ToString
import com.algorand.android.utils.preference.isNotificationActivated
import com.algorand.android.utils.recordException
import com.google.firebase.messaging.RemoteMessage
import com.google.gson.Gson
import com.walletconnect.android.Core
import com.walletconnect.android.push.notifications.PushMessagingService
import dagger.hilt.android.AndroidEntryPoint
import java.lang.Integer.parseInt
import java.text.SimpleDateFormat
import java.util.Date
import javax.inject.Inject

@AndroidEntryPoint
class PeraFirebaseMessagingService : PushMessagingService() {

    @Inject
    lateinit var peraNotificationManager: PeraNotificationManager

    @Inject
    lateinit var sharedPref: SharedPreferences

    @Inject
    lateinit var firebasePushTokenUseCase: FirebasePushTokenUseCase

    @Inject
    lateinit var gson: Gson

    override fun onNewToken(token: String) {
        firebasePushTokenUseCase.setPushToken(token)
    }

    override fun registeringFailed(token: String, throwable: Throwable) {
        // WC lib function. nothing to do here
    }

    override fun newToken(token: String) {
        // WC lib function. nothing to do here
    }

    override fun onDefaultBehavior(message: RemoteMessage) {
        // WC lib function. nothing to do here
    }

    override fun onError(throwable: Throwable, defaultMessage: RemoteMessage) {
        // WC lib function. nothing to do here
    }

    override fun onMessage(message: Core.Model.Message, originalMessage: RemoteMessage) {
        // WC lib function. nothing to do here
    }

    override fun onMessageReceived(message: RemoteMessage) {
        if (sharedPref.isNotificationActivated().not()) {
            return
        }

        val customDataJson = message.data[CUSTOM]

        val notificationData = if (customDataJson != null) {
            val alertMessage = message.data[ALERT]
            parseCustomData(customDataJson, alertMessage)
        } else {
            val blobDataEncodedJson = message.data[BLOB]
            parseBlobData(blobDataEncodedJson)
        }

        if (peraNotificationManager.newNotificationLiveData.hasActiveObservers()) {
            if (customDataJson != null) {
                showInAppNotification(notificationData)
            }
        } else {
            showNotification(notificationData)
        }
    }

    private fun showInAppNotification(notificationData: NotificationMetadata) {
        peraNotificationManager.newNotificationLiveData.postValue(Event(notificationData))
    }

    @SuppressWarnings("LongMethod")
    private fun showNotification(notificationData: NotificationMetadata) {
        val intent = if (notificationData.url != null) {
            LauncherActivity.newIntentWithDeeplink(context = this, deeplink = notificationData.url)
        } else {
            LauncherActivity.newIntent(context = this)
        }.apply { action = System.currentTimeMillis().toString() }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, 0, intent, flags)

        val notificationBuilder = NotificationCompat.Builder(this, DEFAULT_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_notification_small)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .setContentTitle(notificationData.title ?: getString(R.string.app_name))
            .setContentText(notificationData.alertMessage.orEmpty())
            .setStyle(NotificationCompat.BigTextStyle().bigText(notificationData.alertMessage.orEmpty()))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setDefaults(Notification.DEFAULT_ALL)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val channelId = getString(R.string.app_name)
        val channel = NotificationChannel(
            channelId,
            getString(R.string.app_name),
            NotificationManager.IMPORTANCE_DEFAULT
        )

        notificationManager.createNotificationChannel(channel)
        notificationBuilder.setChannelId(channelId)
        notificationManager.notify(getUniqueId(), notificationBuilder.build())
    }

    private fun getUniqueId(): Int {
        val dateFormatForNotificationId = "HHmmssSS"
        val now = Date()
        return parseInt(SimpleDateFormat(dateFormatForNotificationId).format(now))
    }

    private fun parseCustomData(customDataJson: String?, alertMessage: String?): NotificationMetadata {
        return try {
            gson.fromJson(customDataJson, NotificationMetadata::class.java).apply {
                this.alertMessage = alertMessage
            }
        } catch (exception: Exception) {
            recordException(exception)
            NotificationMetadata()
        }
    }

    private fun parseBlobData(blobDataEncodedJson: String?): NotificationMetadata {
        return try {
            val decodedData = blobDataEncodedJson?.decodeBase64ToString()
            val parsedData = gson.fromJson(decodedData, NotificationWCData::class.java)
            NotificationMetadata(
                url = parsedData.url,
                title = parsedData.title,
                alertMessage = parsedData.body
            )
        } catch (exception: Exception) {
            recordException(exception)
            NotificationMetadata()
        }
    }

    companion object {
        private const val DEFAULT_CHANNEL_ID = "default"
        private const val ALERT = "alert"
        private const val CUSTOM = "custom"
        private const val BLOB = "blob"
    }
}
