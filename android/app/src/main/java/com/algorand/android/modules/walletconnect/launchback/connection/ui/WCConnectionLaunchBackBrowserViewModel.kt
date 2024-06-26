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

package com.algorand.android.modules.walletconnect.launchback.connection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.walletconnect.launchback.base.ui.WcLaunchBackBrowserViewModel
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackBrowserPreview
import com.algorand.android.modules.walletconnect.launchback.connection.ui.usecase.WCConnectionLaunchBackBrowserPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class WCConnectionLaunchBackBrowserViewModel @Inject constructor(
    private val wccConnectionLaunchBackBrowserPreviewUseCase: WCConnectionLaunchBackBrowserPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : WcLaunchBackBrowserViewModel() {

    private val args = WCConnectionLaunchBackBrowserBottomSheetArgs.fromSavedStateHandle(savedStateHandle)

    override val wcLaunchBackBrowserFieldsFlow: StateFlow<WCConnectionLaunchBackBrowserPreview?>
        get() = _wcConnectionLaunchBackBrowserPreviewFlow

    private val _wcConnectionLaunchBackBrowserPreviewFlow = MutableStateFlow<WCConnectionLaunchBackBrowserPreview?>(
        null
    )

    init {
        setWcConnectionLaunchBackBrowserPreviewFlow()
    }

    private fun setWcConnectionLaunchBackBrowserPreviewFlow() {
        viewModelScope.launchIO {
            val preview = wccConnectionLaunchBackBrowserPreviewUseCase.getInitialWcConnectionLaunchBackBrowserPreview(
                sessionIdentifier = args.sessionIdentifier,
            )
            _wcConnectionLaunchBackBrowserPreviewFlow.emit(preview)
        }
    }
}
