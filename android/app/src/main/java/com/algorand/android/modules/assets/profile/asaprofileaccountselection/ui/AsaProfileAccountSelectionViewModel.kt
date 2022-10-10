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

package com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.model.AsaProfileAccountSelectionPreview
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.usecase.AsaProfileAccountSelectionPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class AsaProfileAccountSelectionViewModel @Inject constructor(
    private val asaProfileAccountSelectionPreviewUseCase: AsaProfileAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val assetShortName = savedStateHandle.getOrThrow<String>(ASSET_SHORT_NAME_KEY)

    private val _accountSelectionFlow = MutableStateFlow<AsaProfileAccountSelectionPreview>(
        asaProfileAccountSelectionPreviewUseCase.getInitialAccountSelectionPreview()
    )
    val accountSelectionFlow: StateFlow<AsaProfileAccountSelectionPreview> get() = _accountSelectionFlow

    init {
        initAsaAccountSelectionPreviewFlow()
    }

    private fun initAsaAccountSelectionPreviewFlow() {
        viewModelScope.launch {
            asaProfileAccountSelectionPreviewUseCase.getAccountSelectionPreviewFlow().collect { preview ->
                _accountSelectionFlow.emit(preview)
            }
        }
    }

    companion object {
        private const val ASSET_SHORT_NAME_KEY = "assetShortName"
    }
}
