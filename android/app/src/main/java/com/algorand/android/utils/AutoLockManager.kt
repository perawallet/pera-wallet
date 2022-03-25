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

package com.algorand.android.utils

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.OnLifecycleEvent

class AutoLockManager : LifecycleObserver {

    private var appAtBackground: Long? = null
    val autoLockLiveData = MutableLiveData<Event<Any>>()

    fun registerAppLifecycle(appLifecycle: Lifecycle) {
        appLifecycle.addObserver(this)
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    fun onApplicationComesForeground() {
        checkLockState()
    }

    fun checkLockState() {
        appAtBackground?.let { safeAppAtBackground ->
            val timeInBackground = System.currentTimeMillis() - safeAppAtBackground
            if (timeInBackground > AUTO_LOCK_THRESHOLD) {
                autoLockLiveData.value = Event(Any())
            }
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
    fun onApplicationGoesBackground() {
        appAtBackground = System.currentTimeMillis()
    }

    companion object {
        private const val AUTO_LOCK_THRESHOLD = 60_000
    }
}
