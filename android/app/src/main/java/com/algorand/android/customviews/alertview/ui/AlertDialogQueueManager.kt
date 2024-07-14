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

package com.algorand.android.customviews.alertview.ui

import com.algorand.android.models.AlertMetadata
import com.algorand.android.notification.domain.model.NotificationMetadata
import java.util.ArrayDeque
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Singleton
class AlertDialogQueueManager @Inject constructor() {

    private val alertQueue = ArrayDeque<AlertMetadata>()

    private var listener: Listener? = null

    private var isAlertShown = false

    private var scope: CoroutineScope? = null

    private var timerJob: Job? = null

    fun setScope(lifecycleScope: CoroutineScope) {
        scope = lifecycleScope
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun addAlertError(title: String, description: String, tag: String? = null) {
        addAlert(
            AlertMetadata.AlertError(
                title = title,
                description = description,
                tag = tag
            )
        )
    }

    fun addAlertSuccess(title: String, description: String? = null, tag: String? = null) {
        addAlert(
            AlertMetadata.AlertSuccess(
                title = title,
                description = description,
                tag = tag
            )
        )
    }

    fun addAlertNotification(
        notificationMetadata: NotificationMetadata,
        title: String? = null,
        description: String? = null,
        tag: String? = null
    ) {
        addAlert(
            AlertMetadata.AlertNotification(
                title = title ?: notificationMetadata.alertMessage,
                description = description,
                metadata = notificationMetadata,
                tag = tag
            )
        )
    }

    fun removeAlertsWithTag(tag: String) {
        if (alertQueue.isNotEmpty()) {
            alertQueue.removeIf { it.tag.equals(tag) }
            scope?.launch { timerJob?.cancelAndJoin() }
            if (alertQueue.isEmpty()) {
                listener?.onDismissAlertView()
            } else {
                showNextAlert()
            }
        }
    }

    fun showNextAlert() {
        if (alertQueue.isNotEmpty()) {
            isAlertShown = true
            listener?.onDisplayAlertView(alertQueue.firstOrNull() ?: return)
            startAlertMaxDurationTimeout()
        } else {
            isAlertShown = false
            listener?.onQueueCompleted()
        }
    }

    fun removeHeadOfQueue() {
        if (alertQueue.isNotEmpty()) {
            alertQueue.removeFirst()
            scope?.launch { timerJob?.cancelAndJoin() }
        }
    }

    private fun addAlert(alertMetadata: AlertMetadata) {
        val isThereAnySameAlert = alertQueue.any { it.hashCode() == alertMetadata.hashCode() }
        if (isThereAnySameAlert) return

        alertQueue.add(alertMetadata)
        if (!isAlertShown) {
            showNextAlert()
        }
    }

    private fun dismissCurrentAlert() {
        if (alertQueue.isNotEmpty()) {
            alertQueue.removeFirst()
            listener?.onDismissAlertView()
        }
    }

    private fun startAlertMaxDurationTimeout() {
        timerJob = scope?.launch {
            delay(MAX_SHOWN_DURATION)
            dismissCurrentAlert()
        }
    }

    interface Listener {
        fun onDisplayAlertView(alertMetadata: AlertMetadata)
        fun onDismissAlertView()
        fun onQueueCompleted()
    }

    companion object {
        private const val MAX_SHOWN_DURATION = 3000L
    }
}
