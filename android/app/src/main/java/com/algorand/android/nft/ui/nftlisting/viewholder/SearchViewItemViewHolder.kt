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

package com.algorand.android.nft.ui.nftlisting.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.doOnLayout
import com.algorand.android.customviews.PeraHorizontalSwitchView
import com.algorand.android.databinding.ItemBaseCollectiblesSearchViewBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.nft.ui.model.BaseCollectibleListItem

class SearchViewItemViewHolder(
    private val binding: ItemBaseCollectiblesSearchViewBinding,
    private val listener: Listener
) : BaseViewHolder<BaseCollectibleListItem>(binding.root) {

    private val listingViewTypeListener = object : PeraHorizontalSwitchView.Listener {
        override fun onStartOptionActivated() {
            listener.onGridListingOptionSelected()
        }

        override fun onEndOptionActivated() {
            listener.onLinearVerticalListingOptionSelected()
        }
    }

    override fun bind(item: BaseCollectibleListItem) {
        if (item !is BaseCollectibleListItem.SearchViewItem) return
        with(binding) {
            with(collectibleSearchView) {
                setOnTextChanged(listener::onSearchViewTextChanged)
                text = item.query
            }
            with(nftListingViewTypeSwitchView) {
                item.onLinearListViewSelectedEvent?.consume()?.run { doOnLayout { moveSwitchToEnd() } }
                item.onGridListViewSelectedEvent?.consume()?.run { doOnLayout { moveSwitchToStart() } }
                setListener(listingViewTypeListener)
            }
        }
    }

    interface Listener {
        fun onSearchViewTextChanged(text: String)
        fun onLinearVerticalListingOptionSelected()
        fun onGridListingOptionSelected()
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: Listener
        ): SearchViewItemViewHolder {
            val binding = ItemBaseCollectiblesSearchViewBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return SearchViewItemViewHolder(binding, listener = listener)
        }
    }
}
