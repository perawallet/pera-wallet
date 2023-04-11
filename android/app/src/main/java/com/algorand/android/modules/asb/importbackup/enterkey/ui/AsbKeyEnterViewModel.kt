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

package com.algorand.android.modules.asb.importbackup.enterkey.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.modules.asb.importbackup.enterkey.ui.model.AsbKeyEnterPreview
import com.algorand.android.modules.asb.importbackup.enterkey.ui.usecase.AsbKeyEnterPreviewUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbKeyEnterViewModel @Inject constructor(
    private val asbKeyEnterPreviewUseCase: AsbKeyEnterPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val cipherText = savedStateHandle.getOrThrow<String>(CIPHER_TEXT_KEY)

    private val _asbKeyEnterPreviewFlow = MutableStateFlow(createInitialPreview())
    val asbKeyEnterPreviewFlow: StateFlow<AsbKeyEnterPreview> get() = _asbKeyEnterPreviewFlow

    fun getInitialPassphraseInputGroupConfiguration(): PassphraseInputGroupConfiguration {
        return _asbKeyEnterPreviewFlow.value.passphraseInputGroupConfiguration
    }

    fun onFocusedInputChanged(value: String) {
        _asbKeyEnterPreviewFlow.update { preview ->
            asbKeyEnterPreviewUseCase.updatePreviewAfterFocusedInputChanged(
                preview = preview,
                word = value
            )
        }
    }

    fun onFocusedViewChanged(focusedItemOrder: Int) {
        _asbKeyEnterPreviewFlow.update { preview ->
            asbKeyEnterPreviewUseCase.updatePreviewAfterFocusChanged(
                preview = preview,
                focusedItemOrder = focusedItemOrder
            )
        }
    }

    fun onClipboardTextPasted(clipboardData: String) {
        _asbKeyEnterPreviewFlow.update { preview ->
            asbKeyEnterPreviewUseCase.updatePreviewAfterPastingClipboardData(
                preview = preview,
                clipboardData = clipboardData
            )
        }
    }

    fun onNextButtonClick() {
        viewModelScope.launchIO {
            asbKeyEnterPreviewUseCase.updatePreviewWithKeyValidation(
                preview = _asbKeyEnterPreviewFlow.value,
                cipherText = cipherText
            ).collectLatest { preview ->
                _asbKeyEnterPreviewFlow.emit(preview)
            }
        }
    }

    private fun createInitialPreview(): AsbKeyEnterPreview {
        return asbKeyEnterPreviewUseCase.getRecoverWithPassphraseInitialPreview()
    }

    companion object {
        private const val CIPHER_TEXT_KEY = "ciphertext"
    }
}
