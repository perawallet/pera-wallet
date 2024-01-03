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

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.sessions.ui.adapter.viewholder.WalletConnectSessionItemViewHolder
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem.ItemType.WC_SESSION_ITEM
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier

class WalletConnectSessionItemAdapter(
    private val listener: Listener
) : ListAdapter<BaseWalletConnectSessionItem, BaseViewHolder<BaseWalletConnectSessionItem>>(BaseDiffUtil()) {

    private val walletConnectSessionItemListener = WalletConnectSessionItemViewHolder.Listener { sessionIdentifier ->
        listener.onSessionClick(sessionIdentifier)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseWalletConnectSessionItem> {
        return when (viewType) {
            WC_SESSION_ITEM.ordinal -> createWalletConnectSessionItemViewHolder(parent)
            else -> throw Exception("$logTag : Item View Type is Unknown. $viewType")
        }
    }

    private fun createWalletConnectSessionItemViewHolder(parent: ViewGroup): WalletConnectSessionItemViewHolder {
        return WalletConnectSessionItemViewHolder.create(parent, walletConnectSessionItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseWalletConnectSessionItem>, position: Int) {
        holder.bind(getItem(position))
    }

    fun interface Listener {
        fun onSessionClick(sessionIdentifier: WalletConnectSessionIdentifier)
    }

    companion object {
        private val logTag = WalletConnectSessionItemAdapter::class.simpleName
    }
}
