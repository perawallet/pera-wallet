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

package com.algorand.android.ui.wctransactionrequest.ui.mapper

import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.ui.wctransactionrequest.ui.model.WalletConnectTransactionRequestPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectTransactionRequestPreviewMapper @Inject constructor() {

    fun mapToWalletConnectTransactionRequestPreview(
        navBackEvent: Event<Unit>? = null,
        navToLaunchBackNavigationEvent: Event<WalletConnectSessionIdentifier>? = null
    ): WalletConnectTransactionRequestPreview {
        return WalletConnectTransactionRequestPreview(
            navBackEvent = navBackEvent,
            navToLaunchBackNavigationEvent = navToLaunchBackNavigationEvent
        )
    }
}
