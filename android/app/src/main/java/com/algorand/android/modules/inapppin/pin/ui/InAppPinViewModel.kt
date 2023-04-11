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

package com.algorand.android.modules.inapppin.pin.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.inapppin.pin.ui.model.InAppPinPreview
import com.algorand.android.modules.inapppin.pin.ui.usecase.InAppPinPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class InAppPinViewModel @Inject constructor(
    private val inAppPinPreviewUseCase: InAppPinPreviewUseCase
) : BaseViewModel() {

    private val _inAppPinPreviewFlow = MutableStateFlow<InAppPinPreview?>(null)
    val inAppPinPreviewFlow: StateFlow<InAppPinPreview?> get() = _inAppPinPreviewFlow

    // This job keeps the penalty remaining time coroutine scope. So, we need to ensure that we have assigned
    // pinEntryPreview-related coroutine scope to this
    private var penaltyPreviewJob: Job? = null

    init {
        initInAppPinPreviewFlow()
    }

    fun onBiometricAuthSucceed() {
        viewModelScope.launchIO {
            val preview = inAppPinPreviewUseCase.updatePreviewWithBiometricAuthSucceed(
                preview = _inAppPinPreviewFlow.value
            )
            _inAppPinPreviewFlow.emit(preview)
        }
    }

    fun onRemoveAllDataClick() {
        _inAppPinPreviewFlow.update { preview ->
            inAppPinPreviewUseCase.updatePreviewWithDeletionOfAllDataEvent(preview)
        }
    }

    fun onPinCodeEntered(pinCode: String) {
        viewModelScope.launchIO {
            val preview = inAppPinPreviewUseCase.updatePreviewWithEnteredPinCode(
                preview = _inAppPinPreviewFlow.value,
                pinCode = pinCode
            )
            _inAppPinPreviewFlow.emit(preview)
        }
    }

    fun onStartPenaltyTime() {
        penaltyPreviewJob = viewModelScope.launchIO {
            inAppPinPreviewUseCase.updatePreviewWithPenaltyPreview(
                preview = _inAppPinPreviewFlow.value
            ).collect { preview ->
                _inAppPinPreviewFlow.emit(preview)
            }
        }
    }

    fun onDeletionOfAllDataConfirmed() {
        viewModelScope.launchIO {
            penaltyPreviewJob?.cancel()
            inAppPinPreviewUseCase.updatePreviewWithDeletionOfAllData(
                preview = _inAppPinPreviewFlow.value
            ).collect { preview ->
                _inAppPinPreviewFlow.emit(preview)
            }
        }
    }

    private fun initInAppPinPreviewFlow() {
        penaltyPreviewJob = viewModelScope.launchIO {
            inAppPinPreviewUseCase.getInAppPinPreview().collect { preview ->
                _inAppPinPreviewFlow.emit(preview)
            }
        }
    }
}
