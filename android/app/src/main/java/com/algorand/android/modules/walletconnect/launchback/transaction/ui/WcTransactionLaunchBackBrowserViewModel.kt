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

package com.algorand.android.modules.walletconnect.launchback.transaction.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.walletconnect.launchback.base.ui.WcLaunchBackBrowserViewModel
import com.algorand.android.modules.walletconnect.launchback.transaction.ui.model.WcTransactionLaunchBackBrowserPreview
import com.algorand.android.modules.walletconnect.launchback.transaction.ui.usecase.WcTransactionLaunchBackBrowserPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class WcTransactionLaunchBackBrowserViewModel @Inject constructor(
    private val wcTransactionLaunchBackBrowserPreviewUseCase: WcTransactionLaunchBackBrowserPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : WcLaunchBackBrowserViewModel() {

    private val args = WcTransactionLaunchBackBrowserBottomSheetArgs.fromSavedStateHandle(savedStateHandle)

    override val wcLaunchBackBrowserFieldsFlow: StateFlow<WcTransactionLaunchBackBrowserPreview?>
        get() = _wcTransactionLaunchBackBrowserPreviewFlow

    private val _wcTransactionLaunchBackBrowserPreviewFlow = MutableStateFlow<WcTransactionLaunchBackBrowserPreview?>(
        null
    )

    init {
        setWcTransactionLaunchBackBrowserPreviewFlow()
    }

    private fun setWcTransactionLaunchBackBrowserPreviewFlow() {
        viewModelScope.launchIO {
            val preview = wcTransactionLaunchBackBrowserPreviewUseCase.getInitialWcTransactionLaunchBackBrowserPreview(
                sessionIdentifier = args.sessionIdentifier
            )
            _wcTransactionLaunchBackBrowserPreviewFlow.emit(preview)
        }
    }
}
