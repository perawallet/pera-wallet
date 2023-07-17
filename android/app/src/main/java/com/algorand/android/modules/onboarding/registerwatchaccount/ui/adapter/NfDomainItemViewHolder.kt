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

package com.algorand.android.modules.onboarding.registerwatchaccount.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemNfDomainBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.onboarding.registerwatchaccount.ui.model.BasePasteableWatchAccountItem
import com.algorand.android.utils.loadImage

class NfDomainItemViewHolder(
    private val binding: ItemNfDomainBinding,
    private val listener: Listener
) : BaseViewHolder<BasePasteableWatchAccountItem>(binding.root) {

    override fun bind(item: BasePasteableWatchAccountItem) {
        if (item !is BasePasteableWatchAccountItem.NfDomainItem) return
        with(binding.nfDomainItemView) {
            setTitleText(item.formattedNfDomainAccountAddress)
            setDescriptionText(item.nfDomainName)
            context.loadImage(
                uri = item.nfDomainLogoUrl.orEmpty(),
                onResourceReady = { setStartIconDrawable(it) },
                onLoadFailed = { setStartIconResource(R.drawable.ic_nfd_round) }
            )
            setOnClickListener { listener.onNfDomainClick(item.nfDomainName, item.nfDomainAccountAddress) }
        }
    }

    fun interface Listener {
        fun onNfDomainClick(nfDomainName: String, nfDomainAddress: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): NfDomainItemViewHolder {
            val binding = ItemNfDomainBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return NfDomainItemViewHolder(binding, listener)
        }
    }
}
