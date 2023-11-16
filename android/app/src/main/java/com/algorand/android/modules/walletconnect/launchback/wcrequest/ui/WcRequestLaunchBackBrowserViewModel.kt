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

package com.algorand.android.modules.walletconnect.launchback.wcrequest.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.launchback.base.ui.WcLaunchBackBrowserViewModel
import com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.model.WcRequestLaunchBackBrowserPreview
import com.algorand.android.modules.walletconnect.launchback.wcrequest.ui.usecase.WcRequestLaunchBackBrowserPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class WcRequestLaunchBackBrowserViewModel @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val wcRequestLaunchBackBrowserPreviewUseCase: WcRequestLaunchBackBrowserPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : WcLaunchBackBrowserViewModel() {

    private val args = WcRequestLaunchBackBrowserBottomSheetArgs.fromSavedStateHandle(savedStateHandle)

    override val wcLaunchBackBrowserFieldsFlow: StateFlow<WcRequestLaunchBackBrowserPreview?>
        get() = _wcRequestLaunchBackBrowserPreviewFlow

    private val _wcRequestLaunchBackBrowserPreviewFlow = MutableStateFlow<WcRequestLaunchBackBrowserPreview?>(
        null
    )

    init {
        setWcRequestLaunchBackBrowserPreviewFlow()
    }

    private fun setWcRequestLaunchBackBrowserPreviewFlow() {
        viewModelScope.launchIO {
            val preview = wcRequestLaunchBackBrowserPreviewUseCase.getInitialWcRequestLaunchBackBrowserPreview(
                sessionIdentifier = args.sessionIdentifier,
                walletConnectRequest = args.walletConnectRequest
            )
            _wcRequestLaunchBackBrowserPreviewFlow.emit(preview)
        }
    }
}
