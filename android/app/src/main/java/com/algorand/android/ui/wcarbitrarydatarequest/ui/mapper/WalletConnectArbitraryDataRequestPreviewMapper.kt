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

package com.algorand.android.ui.wcarbitrarydatarequest.ui.mapper

import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.ui.wcarbitrarydatarequest.ui.model.WalletConnectArbitraryDataRequestPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WalletConnectArbitraryDataRequestPreviewMapper @Inject constructor() {

    fun mapToWalletConnectArbitraryDataRequestPreview(
        navBackEvent: Event<Unit>? = null,
        navToLaunchBackNavigationEvent: Event<WalletConnectSessionIdentifier>? = null
    ): WalletConnectArbitraryDataRequestPreview {
        return WalletConnectArbitraryDataRequestPreview(
            navBackEvent = navBackEvent,
            navToLaunchBackNavigationEvent = navToLaunchBackNavigationEvent
        )
    }
}
