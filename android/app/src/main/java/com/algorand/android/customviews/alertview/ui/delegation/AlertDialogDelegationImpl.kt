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

package com.algorand.android.customviews.alertview.ui.delegation

import android.content.Context
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.customviews.alertview.ui.AlertDialogQueueManager
import com.algorand.android.customviews.alertview.ui.CustomAlertDialog
import com.algorand.android.models.AlertMetadata
import com.algorand.android.notification.domain.model.NotificationMetadata
import com.algorand.android.utils.emptyString
import dagger.hilt.EntryPoint
import dagger.hilt.InstallIn
import dagger.hilt.android.EntryPointAccessors
import dagger.hilt.android.components.ActivityComponent

class AlertDialogDelegationImpl : AlertDialogDelegation, DefaultLifecycleObserver {

    private var appCompatActivity: AppCompatActivity? = null
    private var customAlertDialog: CustomAlertDialog? = null
    private var listener: Listener? = null
    private var alertDialogQueueManager: AlertDialogQueueManager? = null

    private val alertDialogQueueManagerListener = object : AlertDialogQueueManager.Listener {
        override fun onDisplayAlertView(alertMetadata: AlertMetadata) {
            customAlertDialog?.displayAlertView(alertMetadata)
        }

        override fun onDismissAlertView() {
            customAlertDialog?.dismissCurrentAlertView()
        }

        override fun onQueueCompleted() {
            customAlertDialog?.cancel()
        }
    }

    private val customAlertDialogListener = object : CustomAlertDialog.Listener {
        override fun onTransactionAlertClick(uri: String) {
            listener?.handleDeepLink(uri)
        }

        override fun onAlertViewHidden() {
            alertDialogQueueManager?.showNextAlert()
        }

        override fun onAlertViewCancelled() {
            alertDialogQueueManager?.removeHeadOfQueue()
        }
    }

    override fun registerAlertDialogDelegation(activity: AppCompatActivity, listener: Listener) {
        this.listener = listener
        this.appCompatActivity = activity as? MainActivity
        bindToActivityLifecycle(activity.lifecycle)
        initCustomAlertDialog(activity)
        initAlertDialogQueueManager(activity)
    }

    override fun showGlobalError(errorMessage: CharSequence?, title: String?, tag: String) {
        val safeTitle = title ?: appCompatActivity?.getString(R.string.error_default_title) ?: emptyString()
        val safeErrorMessage =
            errorMessage?.toString() ?: appCompatActivity?.getString(R.string.unknown_error) ?: emptyString()
        alertDialogQueueManager?.addAlertError(
            title = safeTitle,
            description = safeErrorMessage,
            tag = tag
        )
    }

    override fun showForegroundNotification(notificationMetadata: NotificationMetadata, tag: String) {
        alertDialogQueueManager?.addAlertNotification(
            notificationMetadata = notificationMetadata,
            tag = tag
        )
    }

    override fun showAlertSuccess(title: String, description: String?, tag: String) {
        alertDialogQueueManager?.addAlertSuccess(
            title = title,
            description = description,
            tag = tag
        )
    }

    override fun removeAlertsWithTag(tag: String) {
        alertDialogQueueManager?.removeAlertsWithTag(tag)
    }

    private fun bindToActivityLifecycle(lifecycle: Lifecycle) {
        lifecycle.addObserver(this)
    }

    private fun initCustomAlertDialog(context: Context) {
        customAlertDialog = CustomAlertDialog(context).apply {
            setListener(customAlertDialogListener)
        }
    }

    private fun initAlertDialogQueueManager(appCompatActivity: AppCompatActivity) {
        with(appCompatActivity) {
            val entryPoint = EntryPointAccessors.fromActivity(this, AlertDialogDelegationEntryPoint::class.java)
            alertDialogQueueManager = entryPoint.provideAlertDialogQueueManager().apply {
                setScope(lifecycleScope)
                setListener(alertDialogQueueManagerListener)
            }
        }
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        if (customAlertDialog != null && customAlertDialog?.isShowing == true) {
            customAlertDialog?.dismiss()
        }
    }

    fun interface Listener {
        fun handleDeepLink(uri: String)
    }

    @EntryPoint
    @InstallIn(ActivityComponent::class)
    interface AlertDialogDelegationEntryPoint {
        fun provideAlertDialogQueueManager(): AlertDialogQueueManager
    }
}
