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

package com.algorand.android.modules.walletconnect.sessions.ui.mapper

import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionItem
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionsPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectSessionsPreviewMapper @Inject constructor() {

    fun mapToWalletConnectSessionsPreview(
        walletConnectSessionList: List<WalletConnectSessionItem>,
        isDisconnectAllSessionVisible: Boolean,
        isEmptyStateVisible: Boolean,
        onDisconnectAllSessions: Event<Unit>? = null,
        onNavigateToScanQr: Event<Unit>? = null
    ): WalletConnectSessionsPreview {
        return WalletConnectSessionsPreview(
            walletConnectSessionList = walletConnectSessionList,
            isDisconnectAllSessionVisible = isDisconnectAllSessionVisible,
            isEmptyStateVisible = isEmptyStateVisible,
            onDisconnectAllSessions = onDisconnectAllSessions,
            onNavigateToScanQr = onNavigateToScanQr
        )
    }
}
