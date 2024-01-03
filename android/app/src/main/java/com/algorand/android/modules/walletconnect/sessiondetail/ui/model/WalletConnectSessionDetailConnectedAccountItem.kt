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

package com.algorand.android.modules.walletconnect.sessiondetail.ui.model

import android.graphics.drawable.Drawable
import androidx.annotation.ColorRes
import com.algorand.android.models.RecyclerListItem

data class WalletConnectSessionDetailConnectedAccountItem(
    val accountAddress: String,
    val accountPrimaryText: String,
    val accountSecondaryText: String,
    val accountIconDrawable: Drawable?,
    val isAccountSecondaryTextVisible: Boolean,
    val connectedNodeItemList: List<ConnectedNodeItem>
) : RecyclerListItem {

    data class ConnectedNodeItem(
        val nodeName: String,
        @ColorRes val textColorResId: Int
    )

    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is WalletConnectSessionDetailConnectedAccountItem && other.accountAddress == accountAddress
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is WalletConnectSessionDetailConnectedAccountItem && other == this
    }
}
