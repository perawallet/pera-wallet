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

package com.algorand.android.modules.autolockmanager.ui.usecase

import com.algorand.android.modules.autolockmanager.domain.usecase.SetAppAtBackgroundTimeUseCase
import com.algorand.android.modules.autolockmanager.domain.usecase.ShouldAppLockedUseCase
import com.algorand.android.modules.autolockmanager.domain.usecase.ShouldAppLockedUseCase.Companion.appAtBackgroundDefaultPreference
import javax.inject.Inject

class AutoLockManagerUseCase @Inject constructor(
    private val setAppAtBackgroundTimeUseCase: SetAppAtBackgroundTimeUseCase,
    private val shouldAppLockedUseCase: ShouldAppLockedUseCase
) {

    fun setAppAtBackgroundTime(appAtBackgroundTime: Long) {
        setAppAtBackgroundTimeUseCase.invoke(appAtBackgroundTime)
    }

    fun clearAppAtBackgroundTime() {
        setAppAtBackgroundTimeUseCase.invoke(appAtBackgroundDefaultPreference)
    }

    fun shouldAppLocked(): Boolean {
        return shouldAppLockedUseCase.invoke()
    }
}
