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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate

import com.algorand.android.modules.walletconnect.domain.model.WalletConnect

interface WalletConnectV2ClientWalletDelegateListener {
    fun onSessionProposal(proposal: WalletConnect.Session.Proposal)
    fun onSessionUpdate(update: WalletConnect.Session.Update)
    fun onSessionDelete(delete: WalletConnect.Session.Delete)
    fun onSessionSettleSuccess(settle: WalletConnect.Session.Settle.Result)
    fun onSessionSettleFail(error: WalletConnect.Session.Settle.Error)
    fun onSessionRequest(sessionRequest: WalletConnect.Model.SessionRequest)
    fun onConnectionChanged(isAvailable: Boolean)
    fun onError(error: WalletConnect.Model.Error)
}
