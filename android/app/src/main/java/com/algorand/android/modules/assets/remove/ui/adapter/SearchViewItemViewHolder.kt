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

package com.algorand.android.modules.assets.remove.ui.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemRemoveAssetSearchBinding
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.BaseViewHolder

class SearchViewItemViewHolder(
    private val binding: ItemRemoveAssetSearchBinding,
    private val listener: SearchViewItemListener
) : BaseViewHolder<BaseRemoveAssetItem>(binding.root) {
    override fun bind(item: BaseRemoveAssetItem) {
        if (item !is BaseRemoveAssetItem.SearchViewItem) return
        binding.assetSearchView.apply {
            hint = resources.getString(item.searchViewHintResId)
            setOnTextChanged(listener::onSearchQueryUpdate)
        }
    }

    fun interface SearchViewItemListener {
        fun onSearchQueryUpdate(query: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: SearchViewItemListener): SearchViewItemViewHolder {
            val binding = ItemRemoveAssetSearchBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SearchViewItemViewHolder(binding, listener)
        }
    }
}
