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

package com.algorand.android.modules.walletconnect.sessiondetail.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectSessionDetailAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailConnectedAccountItem
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailConnectedAccountItem.ConnectedNodeItem

class WalletConnectSessionDetailConnectedAccountViewHolder(
    private val binding: ItemWalletConnectSessionDetailAccountBinding,
    private val listener: AccountItemLongClickListener
) : BaseViewHolder<WalletConnectSessionDetailConnectedAccountItem>(binding.root) {

    override fun bind(item: WalletConnectSessionDetailConnectedAccountItem) {
        initConnectedNodes(item.connectedNodeItemList)
        with(binding) {
            accountPrimaryTextView.text = item.accountPrimaryText
            accountSecondaryTextView.apply {
                text = item.accountSecondaryText
                isVisible = item.isAccountSecondaryTextVisible
            }
            accountIconImageView.setImageDrawable(item.accountIconDrawable)
            root.setOnLongClickListener { listener.onLongClick(item.accountAddress); true }
        }
    }

    private fun initConnectedNodes(connectedNodeItemList: List<ConnectedNodeItem>) {
        binding.connectedNodesContainer.apply {
            removeAllViews()
            connectedNodeItemList.forEach { nodeItem ->
                val textView = TextView(context).apply {
                    text = resources.getString(R.string.interpunct_and_text, nodeItem.nodeName)
                    setTextColor(ContextCompat.getColor(context, nodeItem.textColorResId))
                }
                addView(textView)
            }
        }
    }

    fun interface AccountItemLongClickListener {
        fun onLongClick(address: String)
    }

    companion object {

        fun create(
            parent: ViewGroup,
            listener: AccountItemLongClickListener
        ): WalletConnectSessionDetailConnectedAccountViewHolder {
            val binding = ItemWalletConnectSessionDetailAccountBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectSessionDetailConnectedAccountViewHolder(binding, listener)
        }
    }
}
