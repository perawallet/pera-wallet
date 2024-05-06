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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.mapper

import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import javax.inject.Inject

class WCSessionRequestResultMapper @Inject constructor() {

    fun mapToApproveRequest(
        accountAddresses: List<String>,
        sessionProposal: WalletConnectSessionProposal
    ): WCSessionRequestResult.ApproveRequest {
        return WCSessionRequestResult.ApproveRequest(
            sessionProposal = sessionProposal,
            accountAddresses = accountAddresses
        )
    }

    fun mapToRejectRequest(sessionProposal: WalletConnectSessionProposal): WCSessionRequestResult.RejectRequest {
        return WCSessionRequestResult.RejectRequest(sessionProposal = sessionProposal)
    }

    fun mapToRejectScamRequest(sessionProposal: WalletConnectSessionProposal):
            WCSessionRequestResult.RejectScamRequest {
        return WCSessionRequestResult.RejectScamRequest(sessionProposal = sessionProposal)
    }
}
