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

package com.algorand.android.modules.walletconnect.connectedapps.ui.mapper

import com.algorand.android.modules.walletconnect.connectedapps.ui.model.WalletConnectConnectedAppsPreview
import com.algorand.android.modules.walletconnect.connectedapps.ui.model.WalletConnectSessionItem
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectConnectedAppsPreviewMapper @Inject constructor() {

    fun mapToWalletConnectConnectedAppsPreview(
        walletConnectSessionList: List<WalletConnectSessionItem>,
        navigateBackEvent: Event<Unit>? = null
    ): WalletConnectConnectedAppsPreview {
        return WalletConnectConnectedAppsPreview(
            walletConnectSessionList = walletConnectSessionList,
            navigateBackEvent = navigateBackEvent
        )
    }
}
