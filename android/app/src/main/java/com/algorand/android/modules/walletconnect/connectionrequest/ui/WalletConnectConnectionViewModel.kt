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

package com.algorand.android.modules.walletconnect.connectionrequest.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WalletConnectConnectionPreview
import com.algorand.android.modules.walletconnect.connectionrequest.ui.usecase.WalletConnectConnectionPreviewUseCase
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.utils.Event
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class WalletConnectConnectionViewModel @Inject constructor(
    private val walletConnectConnectionPreviewUseCase: WalletConnectConnectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val sessionProposal = savedStateHandle.getOrThrow<WalletConnectSessionProposal>(SESSION_PROPOSAL_KEY)

    val walletConnectConnectionPreviewFlow: StateFlow<WalletConnectConnectionPreview?>
        get() = _walletConnectConnectionPreviewFlow
    private val _walletConnectConnectionPreviewFlow = MutableStateFlow<WalletConnectConnectionPreview?>(null)

    init {
        initWalletConnectConnectionPreview()
    }

    fun onAccountChecked(accountAddress: String) {
        viewModelScope.launchIO {
            val currentPreview = _walletConnectConnectionPreviewFlow.value ?: return@launchIO
            val preview = walletConnectConnectionPreviewUseCase.updatePreviewStateAccordingToAccountSelection(
                preview = currentPreview,
                accountAddress = accountAddress
            )
            _walletConnectConnectionPreviewFlow.emit(preview)
        }
    }

    fun onConnectSessionConnect() {
        viewModelScope.launchIO {
            _walletConnectConnectionPreviewFlow.update { preview ->
                walletConnectConnectionPreviewUseCase.getApprovedWalletConnectSessionResult(
                    preview = preview,
                    sessionProposal = sessionProposal
                )
            }
        }
    }

    fun onSessionCancelled() {
        viewModelScope.launchIO {
            val currentPreview = _walletConnectConnectionPreviewFlow.value ?: return@launchIO
            val sessionResult = walletConnectConnectionPreviewUseCase.getRejectedWalletConnectSessionResult(
                sessionProposal = sessionProposal
            )
            _walletConnectConnectionPreviewFlow.emit(
                currentPreview.copy(rejectWalletConnectSessionRequest = Event(sessionResult))
            )
        }
    }

    private fun initWalletConnectConnectionPreview() {
        viewModelScope.launchIO {
            val preview = walletConnectConnectionPreviewUseCase.getWalletConnectConnectionPreview(
                sessionProposal = sessionProposal
            )
            _walletConnectConnectionPreviewFlow.emit(preview)
        }
    }

    companion object {
        private const val SESSION_PROPOSAL_KEY = "sessionProposal"
    }
}
