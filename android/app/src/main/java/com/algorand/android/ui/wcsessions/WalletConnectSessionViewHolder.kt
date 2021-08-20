/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.wcsessions

import android.content.res.ColorStateList
import android.view.ContextMenu
import android.view.LayoutInflater
import android.view.Menu
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.PopupMenu
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectSessionBinding
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.utils.formatAsDateAndTime
import com.algorand.android.utils.getZonedDateTimeFromSec
import com.algorand.android.utils.loadPeerMetaIcon
import com.algorand.android.utils.toShortenedAddress

class WalletConnectSessionViewHolder(
    private val binding: ItemWalletConnectSessionBinding,
    private val onDisconnectClick: (WalletConnectSession) -> Unit
) : RecyclerView.ViewHolder(binding.root), View.OnCreateContextMenuListener {

    private lateinit var session: WalletConnectSession

    override fun onCreateContextMenu(menu: ContextMenu?, v: View?, menuInfo: ContextMenu.ContextMenuInfo?) {
        menu?.apply {
            add(Menu.NONE, binding.moreButton.id, Menu.NONE, R.string.disconnect)
        }
    }

    fun bind(session: WalletConnectSession) {
        this.session = session
        with(binding) {
            with(session.peerMeta) {
                iconImageView.loadPeerMetaIcon(peerIconUri?.toString())
                appNameTextView.text = name
                appDescriptionTextView.apply {
                    isVisible = hasDescription
                    text = description
                }
            }
            setConnectionIndicatorTextView(session)
            dateTextView.text = getZonedDateTimeFromSec(session.dateTimeStamp)?.formatAsDateAndTime()
            moreButton.apply {
                setOnClickListener { showPopUpMenu(this, session) }
            }
        }
    }

    private fun setConnectionIndicatorTextView(session: WalletConnectSession) {
        with(binding.connectionIndicatorTextView) {
            val shortenedAddress = session.connectedAccountPublicKey.toShortenedAddress()
            text = if (session.isConnected) {
                setBackgroundResource(R.drawable.bg_connected_session_indicator)
                setTextColor(ColorStateList.valueOf(ContextCompat.getColor(context, R.color.green_0D)))
                context.getString(R.string.connected_with_formatted, shortenedAddress)
            } else {
                background = null
                setPadding(0, 0, 0, 0)
                setTextColor(ColorStateList.valueOf(ContextCompat.getColor(context, R.color.gray_8A)))
                shortenedAddress
            }
        }
    }

    private fun showPopUpMenu(view: View, session: WalletConnectSession) {
        PopupMenu(view.context, view).apply {
            menuInflater.inflate(R.menu.wallet_connect_session_menu, menu)
            setOnMenuItemClickListener { onDisconnectClick(session); true }
            show()
        }
    }

    companion object {
        fun create(
            parent: ViewGroup,
            onDisconnectClick: (WalletConnectSession) -> Unit
        ): WalletConnectSessionViewHolder {
            val binding = ItemWalletConnectSessionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectSessionViewHolder(binding, onDisconnectClick)
        }
    }
}
