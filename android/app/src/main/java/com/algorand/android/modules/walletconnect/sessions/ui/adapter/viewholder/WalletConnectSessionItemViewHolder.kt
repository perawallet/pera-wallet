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

package com.algorand.android.modules.walletconnect.sessions.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.databinding.ItemWalletConnectSessionListBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem.WalletConnectSessionItem.ConnectionState
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem.WalletConnectSessionItem.SessionBadge
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon

class WalletConnectSessionItemViewHolder(
    private val binding: ItemWalletConnectSessionListBinding,
    private val listener: Listener
) : BaseViewHolder<BaseWalletConnectSessionItem>(binding.root) {

    override fun bind(item: BaseWalletConnectSessionItem) {
        if (item !is BaseWalletConnectSessionItem.WalletConnectSessionItem) return
        with(binding) {
            dAppIconImageView.loadPeerMetaIcon(item.dAppIconUrl.toString())
            dAppNameTextView.text = item.dAppName
            sessionDetailTextView.text = root.context.getXmlStyledString(item.descriptionAnnotatedString)
            root.setOnClickListener { listener.onSessionClick(item.sessionIdentifier) }
        }
        setConnectionStatusView(item.connectionState)
        setSessionBadgeView(item.sessionBadge)
    }

    private fun setConnectionStatusView(connectionState: ConnectionState) {
        with(binding.sessionStatusTextView) {
            setText(connectionState.stateName)
            setTextColor(ContextCompat.getColor(context, connectionState.stateTextColorResId))
            backgroundTintList = ContextCompat.getColorStateList(context, connectionState.stateBackgroundColorResId)
            setBackgroundResource(connectionState.stateBackgroundResId)
        }
    }

    private fun setSessionBadgeView(sessionBadge: SessionBadge?) {
        with(binding.sessionBadgeTextView) {
            isVisible = sessionBadge != null
            if (sessionBadge == null) return

            setText(sessionBadge.badgeName)
            setTextColor(ContextCompat.getColor(context, sessionBadge.badgeTextColorResId))
            backgroundTintList = ContextCompat.getColorStateList(context, sessionBadge.badgeBackgroundColorResId)
            setBackgroundResource(sessionBadge.badgeBackgroundResId)
        }
    }

    fun interface Listener {
        fun onSessionClick(sessionIdentifier: WalletConnectSessionIdentifier)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): WalletConnectSessionItemViewHolder {
            val binding = ItemWalletConnectSessionListBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return WalletConnectSessionItemViewHolder(binding, listener)
        }
    }
}
