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

package com.algorand.android.utils.walletconnect

import androidx.lifecycle.LiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.WalletConnectRequest
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.launch

@HiltViewModel
class WalletConnectViewModel @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val walletConnectUrlHandler: WalletConnectUrlHandler
) : BaseViewModel() {

    val sessionResultFlow: SharedFlow<Event<Resource<WalletConnectSessionProposal>>>
        get() = walletConnectManager.sessionResultFlow

    val walletConnectRequestLiveData: LiveData<Event<Resource<WalletConnectRequest>>?>
        get() = walletConnectManager.walletConnectRequestLiveData

    val invalidTransactionCauseLiveData
        get() = walletConnectManager.invalidTransactionCauseLiveData

    val localSessionsFlow: Flow<List<WalletConnect.SessionDetail>>
        get() = walletConnectManager.localSessionsFlow

    val sessionSettleFlow: Flow<Event<WalletConnectSessionIdentifier>>
        get() = walletConnectManager.sessionSettleFlow

    fun connectToSessionByUrl(url: String) {
        walletConnectManager.connectToNewSession(url)
    }

    fun approveSession(result: WCSessionRequestResult.ApproveRequest) {
        with(result) {
            viewModelScope.launch {
                walletConnectManager.approveSession(sessionProposal, accountAddresses)
            }
        }
    }

    fun rejectSession(sessionProposal: WalletConnectSessionProposal) {
        viewModelScope.launch(Dispatchers.IO) {
            walletConnectManager.rejectSession(sessionProposal)
        }
    }

    fun handleWalletConnectUrl(url: String, listener: WalletConnectUrlHandler.Listener) {
        walletConnectUrlHandler.checkWalletConnectUrl(url, listener)
    }

    fun setWalletConnectSessionTimeoutListener(onSessionTimedOut: () -> Unit) {
        walletConnectManager.onSessionTimedOut = onSessionTimedOut
    }
}
