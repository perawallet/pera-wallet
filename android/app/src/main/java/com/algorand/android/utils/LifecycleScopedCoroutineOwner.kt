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
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.coroutineScope
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.SupervisorJob

abstract class LifecycleScopedCoroutineOwner {

    lateinit var currentScope: CoroutineScope
    private var lifecycle: Lifecycle? = null

    fun assignToLifecycle(lifecycle: Lifecycle) {
        if (this.lifecycle == null) {
            this.lifecycle = lifecycle
            currentScope = CoroutineScope(lifecycle.coroutineScope.coroutineContext + SupervisorJob())
            addDestroyObserver()
        }
    }

    abstract fun stopAllResources()

    private fun addDestroyObserver() {
        lifecycle?.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_DESTROY) {
                    stopAllResources()
                    lifecycle?.removeObserver(this)
                }
            }
        })
    }
}
