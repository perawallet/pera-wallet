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

package com.algorand.android.ui.settings

import android.app.NotificationManager
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.settings.ui.model.SettingsPreview
import com.algorand.android.modules.settings.ui.usecase.SettingsPreviewUseCase
import com.algorand.android.usecase.DeleteAllDataUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val deleteAllDataUseCase: DeleteAllDataUseCase,
    private val settingsPreviewUseCase: SettingsPreviewUseCase
) : BaseViewModel() {

    private val _settingsPreviewFlow = MutableStateFlow<SettingsPreview?>(null)
    val settingsPreviewFlow: StateFlow<SettingsPreview?> get() = _settingsPreviewFlow

    init {
        initSettingsPreviewFlow()
    }

    fun deleteAllData(notificationManager: NotificationManager?, onDeletionCompleted: () -> Unit) {
        viewModelScope.launch {
            deleteAllDataUseCase.deleteAllData(notificationManager, onDeletionCompleted)
        }
    }

    private fun initSettingsPreviewFlow() {
        viewModelScope.launchIO {
            settingsPreviewUseCase.getSettingsPreviewFlow().collectLatest { preview ->
                _settingsPreviewFlow.emit(preview)
            }
        }
    }
}
