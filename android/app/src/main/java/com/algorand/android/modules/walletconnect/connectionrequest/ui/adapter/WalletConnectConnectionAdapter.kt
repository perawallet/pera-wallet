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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem.ItemType.ACCOUNTS_TITLE_ITEM
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem.ItemType.ACCOUNT_ITEM
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem.ItemType.DAPP_INFO_ITEM

class WalletConnectConnectionAdapter(
    private val listener: WalletConnectConnectionAdapterListener
) : ListAdapter<BaseWalletConnectConnectionItem, BaseViewHolder<BaseWalletConnectConnectionItem>>(BaseDiffUtil()) {

    private val accountItemListener = WalletConnectConnectionAccountItemViewHolder.Listener { accountAddress ->
        listener.onAccountChecked(accountAddress)
    }

    private val dappInfoItemListAdapter = WalletConnectConnectionDappInfoViewItemHolder.Listener { dappUrl ->
        listener.onDappUrlClick(dappUrl)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseWalletConnectConnectionItem> {
        return when (viewType) {
            DAPP_INFO_ITEM.ordinal -> createDappInfoItemViewHolder(parent)
            ACCOUNTS_TITLE_ITEM.ordinal -> createAccountsTitleItemViewHolder(parent)
            ACCOUNT_ITEM.ordinal -> createAccountItemViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown {$viewType}")
        }
    }

    private fun createDappInfoItemViewHolder(parent: ViewGroup): WalletConnectConnectionDappInfoViewItemHolder {
        return WalletConnectConnectionDappInfoViewItemHolder.create(parent, dappInfoItemListAdapter)
    }

    private fun createAccountsTitleItemViewHolder(
        parent: ViewGroup
    ): WalletConnectConnectionAccountsTitleViewItemHolder {
        return WalletConnectConnectionAccountsTitleViewItemHolder.create(parent)
    }

    private fun createAccountItemViewHolder(parent: ViewGroup): WalletConnectConnectionAccountItemViewHolder {
        return WalletConnectConnectionAccountItemViewHolder.create(parent, accountItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseWalletConnectConnectionItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface WalletConnectConnectionAdapterListener {
        fun onDappUrlClick(dappUrl: String)
        fun onAccountChecked(accountAddress: String)
    }

    companion object {
        private val logTag = WalletConnectConnectionAdapter::class.simpleName
    }
}
