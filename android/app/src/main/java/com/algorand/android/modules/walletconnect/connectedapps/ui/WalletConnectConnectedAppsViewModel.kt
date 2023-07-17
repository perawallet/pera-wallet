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

package com.algorand.android.modules.walletconnect.connectedapps.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.walletconnect.connectedapps.ui.domain.WalletConnectConnectedAppsPreviewUseCase
import com.algorand.android.modules.walletconnect.connectedapps.ui.model.WalletConnectConnectedAppsPreview
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest

@HiltViewModel
class WalletConnectConnectedAppsViewModel @Inject constructor(
    private val walletConnectConnectedAppsPreviewUseCase: WalletConnectConnectedAppsPreviewUseCase
) : BaseViewModel() {

    private val _walletConnectConnectedAppsPreviewFlow = MutableStateFlow<WalletConnectConnectedAppsPreview?>(null)
    val walletConnectConnectedAppsPreviewFlow: StateFlow<WalletConnectConnectedAppsPreview?>
        get() = _walletConnectConnectedAppsPreviewFlow

    init {
        initWalletConnectConnectedAppsPreviewFlow()
    }

    fun killWalletConnectSession(sessionIdentifier: WalletConnectSessionIdentifier) {
        viewModelScope.launchIO {
            walletConnectConnectedAppsPreviewUseCase.killWalletConnectSession(sessionIdentifier)
        }
    }

    fun connectToExistingSession(sessionIdentifier: WalletConnectSessionIdentifier) {
        viewModelScope.launchIO {
            walletConnectConnectedAppsPreviewUseCase.connectToExistingSession(sessionIdentifier)
        }
    }

    private fun initWalletConnectConnectedAppsPreviewFlow() {
        viewModelScope.launchIO {
            walletConnectConnectedAppsPreviewUseCase.getWalletConnectConnectedAppsPreviewFlow().collectLatest {
                _walletConnectConnectedAppsPreviewFlow.emit(it)
            }
        }
    }
}
