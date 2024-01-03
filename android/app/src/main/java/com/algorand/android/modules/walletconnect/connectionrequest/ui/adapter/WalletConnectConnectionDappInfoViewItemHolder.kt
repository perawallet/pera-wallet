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
import com.algorand.android.R
import com.algorand.android.databinding.ItemWalletConnectConnectionDappInfoBinding
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.connectionrequest.ui.model.BaseWalletConnectConnectionItem
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.loadPeerMetaIcon

class WalletConnectConnectionDappInfoViewItemHolder(
    private val binding: ItemWalletConnectConnectionDappInfoBinding,
    private val listener: Listener
) : BaseViewHolder<BaseWalletConnectConnectionItem>(binding.root) {

    override fun bind(item: BaseWalletConnectConnectionItem) {
        if (item !is BaseWalletConnectConnectionItem.DappInfoItem) return
        setDappLogo(item.peerIconUri)
        setDappUrl(item.url)
        setDescriptionText(item.name)
    }

    private fun setDappLogo(dappPeerMetaIconUrl: String) {
        binding.appIconImageView.loadPeerMetaIcon(dappPeerMetaIconUrl)
    }

    private fun setDappUrl(dappUrl: String) {
        binding.appUrlTextView.apply {
            text = dappUrl
            if (dappUrl.isNotBlank()) {
                setOnClickListener { listener.onDappUrlClick(dappUrl) }
            }
        }
    }

    private fun setDescriptionText(dappName: String) {
        binding.descriptionTextView.run {
            text = context?.getXmlStyledString(
                AnnotatedString(R.string.wallet_wants_to_connect, listOf("app_name" to dappName))
            )
        }
    }

    fun interface Listener {
        fun onDappUrlClick(dappUrl: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): WalletConnectConnectionDappInfoViewItemHolder {
            val binding =
                ItemWalletConnectConnectionDappInfoBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WalletConnectConnectionDappInfoViewItemHolder(binding, listener)
        }
    }
}
