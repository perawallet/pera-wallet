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

package com.algorand.android.modules.walletconnect.sessions.ui.model

import android.net.Uri
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.models.RecyclerListItem

data class WalletConnectSessionItem(
    val sessionId: Long,
    val dAppLogoUrl: Uri?,
    val dAppName: String,
    val dAppDescription: String?,
    val connectionDate: String?,
    val connectedAccountItems: List<ConnectedSessionAccountItem>?,
    val isConnected: Boolean
) : RecyclerListItem {

    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is WalletConnectSessionItem && sessionId == other.sessionId
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is WalletConnectSessionItem && this == other
    }

    data class ConnectedSessionAccountItem(
        @DrawableRes val backgroundResource: Int?,
        @ColorRes val textColor: Int,
        val displayName: String
    )
}
