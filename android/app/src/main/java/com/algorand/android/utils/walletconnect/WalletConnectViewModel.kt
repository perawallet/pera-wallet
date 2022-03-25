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

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.WCSessionRequestResult
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.SharedFlow

@Singleton
class WalletConnectViewModel @ViewModelInject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val walletConnectUrlHandler: WalletConnectUrlHandler
) : BaseViewModel() {

    val sessionResultFlow: SharedFlow<Event<Resource<WalletConnectSession>>>
        get() = walletConnectManager.sessionResultFlow

    val requestLiveData: LiveData<Event<Resource<WalletConnectTransaction>>?>
        get() = walletConnectManager.requestLiveData

    val invalidTransactionCauseLiveData
        get() = walletConnectManager.invalidTransactionCauseLiveData

    val localSessionsFlow: Flow<List<WalletConnectSession>>
        get() = walletConnectManager.localSessionsFlow

    fun connectToSessionByUrl(url: String) {
        walletConnectManager.connectToNewSession(url)
    }

    fun connectToSession(session: WalletConnectSession) {
        walletConnectManager.connectToExistingSession(session)
    }

    fun approveSession(result: WCSessionRequestResult.ApproveRequest) {
        with(result) {
            walletConnectManager.approveSession(wcSessionRequest, address)
        }
    }

    fun rejectSession(session: WalletConnectSession) {
        walletConnectManager.rejectSession(session)
    }

    fun killSession(session: WalletConnectSession) {
        walletConnectManager.killSession(session)
    }

    fun handleWalletConnectUrl(url: String, listener: WalletConnectUrlHandler.Listener) {
        walletConnectUrlHandler.checkWalletConnectUrl(url, listener)
    }

    fun setWalletConnectSessionTimeoutListener(onSessionTimedOut: () -> Unit) {
        walletConnectManager.onSessionTimedOut = onSessionTimedOut
    }
}
