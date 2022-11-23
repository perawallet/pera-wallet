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

import android.net.Uri
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionItem
import javax.inject.Inject

class WalletConnectSessionItemMapper @Inject constructor() {

    fun mapToWalletConnectSessionItem(
        sessionId: Long,
        dAppLogoUrl: Uri?,
        dAppName: String,
        dAppDescription: String?,
        connectionDate: String?,
        connectedAccountItems: List<WalletConnectSessionItem.ConnectedSessionAccountItem>?,
        isConnected: Boolean
    ): WalletConnectSessionItem {
        return WalletConnectSessionItem(
            sessionId = sessionId,
            dAppLogoUrl = dAppLogoUrl,
            dAppName = dAppName,
            dAppDescription = dAppDescription,
            connectionDate = connectionDate,
            connectedAccountItems = connectedAccountItems,
            isConnected = isConnected
        )
    }

    fun mapToConnectedSessionAccountItem(
        @DrawableRes backgroundResource: Int?,
        @ColorRes textColor: Int,
        displayName: String
    ): WalletConnectSessionItem.ConnectedSessionAccountItem {
        return WalletConnectSessionItem.ConnectedSessionAccountItem(
            backgroundResource = backgroundResource,
            textColor = textColor,
            displayName = displayName
        )
    }
}
