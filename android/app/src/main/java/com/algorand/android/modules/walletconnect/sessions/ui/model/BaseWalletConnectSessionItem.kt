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
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier

sealed class BaseWalletConnectSessionItem : RecyclerListItem {

    enum class ItemType {
        WC_SESSION_ITEM
    }

    abstract val itemType: ItemType

    data class WalletConnectSessionItem(
        val sessionIdentifier: WalletConnectSessionIdentifier,
        val dAppIconUrl: Uri?,
        val dAppName: String,
        val descriptionAnnotatedString: AnnotatedString,
        val connectionState: ConnectionState,
        val sessionBadge: SessionBadge?
    ) : BaseWalletConnectSessionItem() {

        override val itemType: ItemType
            get() = ItemType.WC_SESSION_ITEM

        data class ConnectionState(
            val stateName: Int,
            val stateTextColorResId: Int,
            val stateBackgroundColorResId: Int,
            val stateBackgroundResId: Int
        )

        data class SessionBadge(
            val badgeName: Int,
            val badgeTextColorResId: Int,
            val badgeBackgroundColorResId: Int,
            val badgeBackgroundResId: Int
        )

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is WalletConnectSessionItem &&
                sessionIdentifier.sessionIdentifier == other.sessionIdentifier.sessionIdentifier
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is WalletConnectSessionItem && this == other
        }
    }

    companion object {
        val excludedItemFromDivider = emptyList<Int>()
    }
}
