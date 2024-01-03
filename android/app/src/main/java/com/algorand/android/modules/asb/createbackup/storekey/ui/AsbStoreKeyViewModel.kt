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

package com.algorand.android.modules.asb.createbackup.storekey.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.asb.createbackup.storekey.ui.model.AsbStoreKeyPreview
import com.algorand.android.modules.asb.createbackup.storekey.ui.usecase.AsbStoreKeyPreviewUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbStoreKeyViewModel @Inject constructor(
    private val asbStoreKeyPreviewUseCase: AsbStoreKeyPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val accountList = savedStateHandle.getOrThrow<Array<String>>(ACCOUNT_LIST_KEY)

    private val _asbStoreKeyPreviewFlow = MutableStateFlow<AsbStoreKeyPreview?>(null)
    val asbStoreKeyPreviewFlow: StateFlow<AsbStoreKeyPreview?> get() = _asbStoreKeyPreviewFlow

    init {
        initAsbStoreKeyPreview()
    }

    fun onDescriptionUrlClick() {
        _asbStoreKeyPreviewFlow.update { preview ->
            asbStoreKeyPreviewUseCase.updatePreviewAfterClickingDescriptionUrl(preview)
        }
    }

    fun onCreateNewKeyClicked() {
        _asbStoreKeyPreviewFlow.update { preview ->
            asbStoreKeyPreviewUseCase.updatePreviewAfterClickingCreateNewKey(preview)
        }
    }

    fun onCreateBackupFileClicked() {
        _asbStoreKeyPreviewFlow.update { preview ->
            asbStoreKeyPreviewUseCase.updatePreviewAfterClickingCreateBackupFile(preview)
        }
    }

    fun onNewKeyCreationConfirmed() {
        viewModelScope.launchIO {
            _asbStoreKeyPreviewFlow.emit(asbStoreKeyPreviewUseCase.updatePreviewWithNewCreatedKey())
        }
    }

    fun onBackupFileCreationConfirmed() {
        viewModelScope.launchIO {
            with(_asbStoreKeyPreviewFlow) {
                value = asbStoreKeyPreviewUseCase.updatePreviewAfterCreatingBackupFile(
                    preview = value,
                    accountList = accountList.toList()
                )
            }
        }
    }

    fun onClipToKeyboardClicked() {
        _asbStoreKeyPreviewFlow.update { preview ->
            asbStoreKeyPreviewUseCase.updatePreviewAfterClickingCopyToKeyboard(preview)
        }
    }

    private fun initAsbStoreKeyPreview() {
        viewModelScope.launchIO {
            _asbStoreKeyPreviewFlow.emit(asbStoreKeyPreviewUseCase.getAsbStoreKeyPreview())
        }
    }

    fun saveBackedUpAccountToLocalStorage() {
        viewModelScope.launchIO {
            asbStoreKeyPreviewUseCase.saveBackedUpAccountToLocalStorage(accountList)
        }
    }

    companion object {
        private const val ACCOUNT_LIST_KEY = "accountList"
    }
}
