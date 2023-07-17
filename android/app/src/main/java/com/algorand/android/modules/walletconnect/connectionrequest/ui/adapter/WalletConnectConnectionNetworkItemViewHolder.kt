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

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectConnectionNetworkBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.WalletConnectConnectionNetworkItem

class WalletConnectConnectionNetworkItemViewHolder(
    private val binding: ItemWalletConnectConnectionNetworkBinding
) : BaseViewHolder<BaseWalletConnectConnectionItem>(binding.root) {

    override fun bind(item: BaseWalletConnectConnectionItem) {
        if (item !is BaseWalletConnectConnectionItem.NetworkItem) return
        with(binding) {
            labelTextView.text = root.resources.getQuantityString(
                R.plurals.networks,
                item.networkCount,
                item.networkCount
            )
            item.networkList.forEach { walletConnectNetworkItem ->
                createNetworkItemTextView(walletConnectNetworkItem)
            }
        }
    }

    private fun createNetworkItemTextView(walletConnectConnectionNetworkItem: WalletConnectConnectionNetworkItem) {
        val textView = TextView(binding.root.context).apply {
            id = ViewCompat.generateViewId()
            setTextAppearance(R.style.TextAppearance_Caption_Bold)
            text = resources.getString(R.string.interpunct_and_text, walletConnectConnectionNetworkItem.networkName)
            setTextColor(ContextCompat.getColor(context, walletConnectConnectionNetworkItem.tintResId))
        }
        binding.rootConstraintLayout.addView(textView)
        binding.networkListFlow.referencedIds += textView.id
    }

    companion object {
        fun create(parent: ViewGroup): WalletConnectConnectionNetworkItemViewHolder {
            val binding = ItemWalletConnectConnectionNetworkBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return WalletConnectConnectionNetworkItemViewHolder(binding)
        }
    }
}
