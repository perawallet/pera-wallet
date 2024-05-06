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

import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WCSessionRequestResult
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WalletConnectConnectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectConnectionPreviewMapper @Inject constructor() {

    fun mapToWalletConnectConnectionPreview(
        baseWalletConnectConnectionItems: List<BaseWalletConnectConnectionItem>,
        isConfirmationButtonEnabled: Boolean,
        approveWalletConnectSessionRequest: Event<WCSessionRequestResult.ApproveRequest>? = null,
        rejectWalletConnectSessionRequest: Event<WCSessionRequestResult.RejectRequest>? = null,
        rejectScamWalletConnectSessionRequest: Event<WCSessionRequestResult.RejectScamRequest>? = null,
    ): WalletConnectConnectionPreview {
        return WalletConnectConnectionPreview(
            baseWalletConnectConnectionItems = baseWalletConnectConnectionItems,
            isConfirmationButtonEnabled = isConfirmationButtonEnabled,
            approveWalletConnectSessionRequest = approveWalletConnectSessionRequest,
            rejectWalletConnectSessionRequest = rejectWalletConnectSessionRequest,
            rejectScamWalletConnectSessionRequest = rejectScamWalletConnectSessionRequest
        )
    }
}
