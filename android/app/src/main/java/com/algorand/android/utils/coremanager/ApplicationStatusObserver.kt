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

package com.algorand.android.utils.coremanager

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.MutableStateFlow

@Singleton
class ApplicationStatusObserver @Inject constructor() : DefaultLifecycleObserver {

    private val isAppOnBackgroundFlow = MutableStateFlow(false)

    val isAppOnBackground: Boolean
        get() = isAppOnBackgroundFlow.value

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        isAppOnBackgroundFlow.value = false
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        isAppOnBackgroundFlow.value = true
    }
}
