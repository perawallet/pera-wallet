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

package com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.ui.model.RecoverWithPassphrasePreview
import com.algorand.android.modules.onboarding.recoverypassphrase.enterpassphrase.ui.usecase.RecoverWithPassphrasePreviewUseCase
import com.algorand.android.utils.getOrElse
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class RecoverWithPassphraseViewModel @Inject constructor(
    private val recoverWithPassphrasePreviewUseCase: RecoverWithPassphrasePreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val mnemonic: String? = savedStateHandle.getOrElse(MNEMONIC_KEY, null)

    private val _recoverWithPassphrasePreviewFlow = MutableStateFlow(createInitialPreview())
    val recoverWithPassphrasePreviewFlow: StateFlow<RecoverWithPassphrasePreview>
        get() = _recoverWithPassphrasePreviewFlow

    private var accountRecoveryJob: Job? = null

    init {
        if (!mnemonic.isNullOrBlank()) {
            onClipboardTextPasted(mnemonic)
        }
    }

    fun getInitialPassphraseInputGroupConfiguration(): PassphraseInputGroupConfiguration {
        return _recoverWithPassphrasePreviewFlow.value.passphraseInputGroupConfiguration
    }

    fun onFocusedInputChanged(value: String) {
        _recoverWithPassphrasePreviewFlow.update { preview ->
            recoverWithPassphrasePreviewUseCase.updatePreviewAfterFocusedInputChanged(
                preview = preview,
                word = value
            )
        }
    }

    fun onFocusedViewChanged(focusedItemOrder: Int) {
        _recoverWithPassphrasePreviewFlow.update { preview ->
            recoverWithPassphrasePreviewUseCase.updatePreviewAfterFocusChanged(
                preview = preview,
                focusedItemOrder = focusedItemOrder
            )
        }
    }

    fun onClipboardTextPasted(clipboardData: String) {
        _recoverWithPassphrasePreviewFlow.update { preview ->
            recoverWithPassphrasePreviewUseCase.updatePreviewAfterPastingClipboardData(
                preview = preview,
                clipboardData = clipboardData
            )
        }
    }

    fun onRecoverButtonClick() {
        if (accountRecoveryJob?.isActive == true) {
            accountRecoveryJob?.cancel()
        }
        accountRecoveryJob = viewModelScope.launch(Dispatchers.IO) {
            recoverWithPassphrasePreviewUseCase.validateEnteredMnemonics(
                preview = _recoverWithPassphrasePreviewFlow.value,
            ).collectLatest { preview ->
                _recoverWithPassphrasePreviewFlow.emit(preview)
            }
        }
    }

    fun cancelAccountRecoveryJob() {
        accountRecoveryJob?.cancel()
        accountRecoveryJob = null
    }

    private fun createInitialPreview(): RecoverWithPassphrasePreview {
        return recoverWithPassphrasePreviewUseCase.getRecoverWithPassphraseInitialPreview()
    }

    companion object {
        private const val MNEMONIC_KEY = "mnemonic"
    }
}
