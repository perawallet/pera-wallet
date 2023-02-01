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

package com.algorand.android.modules.autolockmanager.ui

import android.app.Activity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.algorand.android.MainActivity
import com.algorand.android.modules.autolockmanager.ActivityLifecycleObserver
import com.algorand.android.modules.autolockmanager.ui.usecase.AutoLockManagerUseCase
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Since we have two activity in app lifecycle ([LauncerActivity] and [MainActivity]) I've added a kind of filter,
 * because no need to observer [LauncerActivity].
 */
@Singleton
class AutoLockManager @Inject constructor(
    private val autoLockManagerUseCase: AutoLockManagerUseCase
) : DefaultLifecycleObserver, ActivityLifecycleObserver {

    var isAppUnlocked: Boolean = true
        private set

    private var listener: AutoLockManagerListener? = null

    fun setListener(listener: AutoLockManagerListener) {
        this.listener = listener
    }

    fun onAppUnlocked() {
        unlockApplication()
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        autoLockManagerUseCase.clearAppAtBackgroundTime()
    }

    override fun onActivityResumed(activity: Activity) {
        super.onActivityResumed(activity)
        if (activity !is MainActivity) return
        if (autoLockManagerUseCase.shouldAppLocked() || !isAppUnlocked) {
            lockApplication()
        }
    }

    override fun onActivityPaused(activity: Activity) {
        super.onActivityPaused(activity)
        if (activity !is MainActivity) return
        autoLockManagerUseCase.setAppAtBackgroundTime(System.currentTimeMillis())
    }

    private fun lockApplication() {
        isAppUnlocked = false
        listener?.onLock()
    }

    private fun unlockApplication() {
        isAppUnlocked = true
        listener?.onUnlock()
    }

    interface AutoLockManagerListener {
        fun onLock()
        fun onUnlock()
    }
}
