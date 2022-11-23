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

package com.algorand.android.modules.walletconnect.sessions.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.walletconnect.sessions.ui.domain.WalletConnectSessionsPreviewUseCase
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionsPreview
import com.algorand.android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class WalletConnectSessionsViewModel @Inject constructor(
    private val walletConnectSessionsPreviewUseCase: WalletConnectSessionsPreviewUseCase
) : BaseViewModel() {

    private val _walletConnectSessionsPreviewFlow = MutableStateFlow<WalletConnectSessionsPreview?>(null)
    val walletConnectSessionsPreviewFlow: StateFlow<WalletConnectSessionsPreview?>
        get() = _walletConnectSessionsPreviewFlow

    init {
        initWalletConnectSessionsFlow()
    }

    fun onDisconnectFromAllSessionsClick() {
        viewModelScope.launch {
            val currentPreview = _walletConnectSessionsPreviewFlow.value ?: return@launch
            val newPreview = currentPreview.copy(onDisconnectAllSessions = Event(Unit))
            _walletConnectSessionsPreviewFlow.emit(newPreview)
        }
    }

    fun onScanQrClick() {
        viewModelScope.launch {
            val currentPreview = _walletConnectSessionsPreviewFlow.value ?: return@launch
            val newPreview = currentPreview.copy(onNavigateToScanQr = Event(Unit))
            _walletConnectSessionsPreviewFlow.emit(newPreview)
        }
    }

    fun killWalletConnectSession(sessionId: Long) {
        walletConnectSessionsPreviewUseCase.killWalletConnectSession(sessionId)
    }

    fun connectToExistingSession(sessionId: Long) {
        walletConnectSessionsPreviewUseCase.connectToExistingSession(sessionId)
    }

    fun killAllWalletConnectSessions() {
        walletConnectSessionsPreviewUseCase.killAllWalletConnectSessions()
    }

    private fun initWalletConnectSessionsFlow() {
        viewModelScope.launch {
            walletConnectSessionsPreviewUseCase.getWalletConnectSessionsPreviewFlow().collectLatest {
                _walletConnectSessionsPreviewFlow.emit(it)
            }
        }
    }
}
