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

package com.algorand.android.ui.accountselection.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemNftDomainAccountBinding
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.utils.loadImage
import com.algorand.android.utils.toShortenedAddress

class AccountSelectionNftDomainAccountItemViewHolder(
    private val binding: ItemNftDomainAccountBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: BaseAccountSelectionListItem.BaseAccountItem.NftDomainAccountItem) {
        with(binding) {
            accountAddressTextView.text = item.publicKey.toShortenedAddress()
            nftDomainTextview.text = item.displayName
            serviceLogoImageView.context.loadImage(
                uri = item.serviceLogoUrl.orEmpty(),
                onResourceReady = { serviceLogoImageView.setImageDrawable(it) },
                onLoadFailed = { serviceLogoImageView.setImageResource(R.drawable.ic_nfd_round) }
            )
        }
    }

    companion object {
        fun create(parent: ViewGroup): AccountSelectionNftDomainAccountItemViewHolder {
            val binding = ItemNftDomainAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountSelectionNftDomainAccountItemViewHolder(binding)
        }
    }
}
