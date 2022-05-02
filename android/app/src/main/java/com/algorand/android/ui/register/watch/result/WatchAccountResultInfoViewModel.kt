/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ui.register.watch.result

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import com.algorand.android.usecase.LockPreferencesUseCase
import com.algorand.android.usecase.WatchAccountAdditionResultInfoUseCase

class WatchAccountResultInfoViewModel @ViewModelInject constructor(
    watchAccountAdditionResultInfoUseCase: WatchAccountAdditionResultInfoUseCase,
    private val lockPreferencesUseCase: LockPreferencesUseCase
) : ViewModel() {

    private val watchAccountAdditionResultInfoPreview =
        watchAccountAdditionResultInfoUseCase.getWatchAccountAdditionResultInfoPreview()

    fun shouldForceLockNavigation(): Boolean {
        return lockPreferencesUseCase.shouldNavigateLockNavigation()
    }

    fun getPreviewTitle(): Int {
        return watchAccountAdditionResultInfoPreview.titleTextRes
    }

    fun getPreviewDescription(): Int {
        return watchAccountAdditionResultInfoPreview.descriptionTextRes
    }

    fun getPreviewFirstButtonText(): Int {
        return watchAccountAdditionResultInfoPreview.firstButtonTextRes
    }
}
