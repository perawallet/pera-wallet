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
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WalletConnectConnectionPreview
import com.algorand.android.modules.walletconnect.connectionrequest.ui.usecase.WalletConnectConnectionPreviewUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class WalletConnectConnectionViewModel @Inject constructor(
    private val walletConnectConnectionPreviewUseCase: WalletConnectConnectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val sessionRequest = savedStateHandle.getOrThrow<WalletConnectSession>(SESSION_REQUEST_KEY)

    val peerMetaName: String
        get() = sessionRequest.peerMeta.name

    val walletConnectConnectionPreviewFlow: StateFlow<WalletConnectConnectionPreview?>
        get() = _walletConnectConnectionPreviewFlow
    private val _walletConnectConnectionPreviewFlow = MutableStateFlow<WalletConnectConnectionPreview?>(null)

    private val selectedAccountAddresses: List<String>
        get() = walletConnectConnectionPreviewFlow.value
            ?.baseWalletConnectConnectionItems
            ?.filterIsInstance<BaseWalletConnectConnectionItem.AccountItem>()
            ?.filter { it.isChecked }
            ?.map { it.accountAddress }
            .orEmpty()

    init {
        initWalletConnectConnectionPreview()
    }

    fun onAccountChecked(accountAddress: String) {
        viewModelScope.launch {
            val currentPreview = _walletConnectConnectionPreviewFlow.value ?: return@launch
            val preview = walletConnectConnectionPreviewUseCase.updatePreviewStateAccordingToAccountSelection(
                preview = currentPreview,
                accountAddress = accountAddress
            )
            _walletConnectConnectionPreviewFlow.emit(preview)
        }
    }

    fun onConnectSessionConnect() {
        viewModelScope.launch {
            val currentPreview = _walletConnectConnectionPreviewFlow.value ?: return@launch
            val sessionResult = walletConnectConnectionPreviewUseCase.getApprovedWalletConnectSessionResult(
                accountAddresses = selectedAccountAddresses,
                wcSessionRequest = sessionRequest
            )
            _walletConnectConnectionPreviewFlow.emit(
                currentPreview.copy(approveWalletConnectSessionRequest = Event(sessionResult))
            )
        }
    }

    fun onSessionCancelled() {
        viewModelScope.launch {
            val currentPreview = _walletConnectConnectionPreviewFlow.value ?: return@launch
            val sessionResult = walletConnectConnectionPreviewUseCase.getRejectedWalletConnectSessionResult(
                wcSessionRequest = sessionRequest
            )
            _walletConnectConnectionPreviewFlow.emit(
                currentPreview.copy(rejectWalletConnectSessionRequest = Event(sessionResult))
            )
        }
    }

    private fun initWalletConnectConnectionPreview() {
        viewModelScope.launch {
            val preview = walletConnectConnectionPreviewUseCase.getWalletConnectConnectionPreview(
                walletConnectPeerMeta = sessionRequest.peerMeta
            )
            _walletConnectConnectionPreviewFlow.emit(preview)
        }
    }

    companion object {
        private const val SESSION_REQUEST_KEY = "sessionRequest"
    }
}
