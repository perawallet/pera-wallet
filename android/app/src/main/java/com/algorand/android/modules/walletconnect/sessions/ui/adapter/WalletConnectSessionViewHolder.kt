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

package com.algorand.android.modules.walletconnect.sessions.ui.adapter

import android.content.res.ColorStateList
import android.text.TextUtils
import android.view.ContextMenu
import android.view.LayoutInflater
import android.view.Menu
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.MarginLayoutParams
import android.widget.TextView
import androidx.appcompat.widget.PopupMenu
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectSessionBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionItem
import com.algorand.android.utils.extensions.changeTextAppearance
import com.algorand.android.utils.loadPeerMetaIcon

class WalletConnectSessionViewHolder(
    private val binding: ItemWalletConnectSessionBinding,
    private val listener: Listener
) : BaseViewHolder<WalletConnectSessionItem>(binding.root), View.OnCreateContextMenuListener {

    override fun onCreateContextMenu(menu: ContextMenu?, v: View?, menuInfo: ContextMenu.ContextMenuInfo?) {
        menu?.apply {
            add(Menu.NONE, binding.moreButton.id, Menu.NONE, R.string.disconnect)
        }
    }

    override fun bind(item: WalletConnectSessionItem) {
        with(binding) {
            with(item) {
                iconImageView.loadPeerMetaIcon(dAppLogoUrl.toString())
                appNameTextView.text = dAppName

                moreButton.apply {
                    setOnClickListener { showPopUpMenu(this, sessionId) }
                }

                appDescriptionTextView.apply {
                    text = dAppDescription
                    isVisible = !dAppDescription.isNullOrBlank() && isShowingDetails
                }

                dateTextView.apply {
                    text = connectionDate
                    isVisible = !connectionDate.isNullOrBlank() && isShowingDetails
                }

                connectedTextView.apply {
                    isVisible = dAppDescription.isNullOrBlank() && !isShowingDetails
                    text = context.getString(R.string.connected)
                }

                connectionsIndicatorLinearLayout.apply {
                    isVisible = !connectedAccountItems.isNullOrEmpty() && isShowingDetails
                    removeAllViews()
                }

                setConnectionIndicatorTextView(connectedAccountItems, isConnected)
                root.setOnClickListener { listener.onSessionClick(sessionId) }
            }
        }
    }

    private fun setConnectionIndicatorTextView(
        connectedAccountItems: List<WalletConnectSessionItem.ConnectedSessionAccountItem>?,
        isConnected: Boolean
    ) {
        if (connectedAccountItems.isNullOrEmpty()) return
        connectedAccountItems.forEach {
            inflateConnectionIndicatorTextView().apply {
                if (it.backgroundResource != null) setBackgroundResource(it.backgroundResource) else background = null

                setTextColor(ColorStateList.valueOf(ContextCompat.getColor(context, it.textColor)))

                text = if (isConnected) {
                    context.getString(R.string.connected_with_formatted, it.displayName)
                } else {
                    it.displayName
                }
            }.run {
                binding.connectionsIndicatorLinearLayout.addView(this)
                updateLayoutParams<MarginLayoutParams> {
                    topMargin = resources.getDimensionPixelOffset(R.dimen.spacing_xsmall)
                }
            }
        }
    }

    private fun showPopUpMenu(view: View, sessionId: Long) {
        PopupMenu(view.context, view).apply {
            menuInflater.inflate(R.menu.wallet_connect_session_menu, menu)
            setOnMenuItemClickListener { listener.onSessionDisconnectClick(sessionId); true }
            show()
        }
    }

    private fun inflateConnectionIndicatorTextView(): TextView {
        return TextView(binding.root.context).apply {
            ellipsize = TextUtils.TruncateAt.END
            maxLines = 2
            changeTextAppearance(R.style.TextAppearance_Footnote_Sans_Medium)
        }
    }

    interface Listener {
        fun onSessionDisconnectClick(sessionId: Long)
        fun onSessionClick(sessionId: Long)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): WalletConnectSessionViewHolder {
            val binding = ItemWalletConnectSessionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectSessionViewHolder(binding, listener)
        }
    }
}
