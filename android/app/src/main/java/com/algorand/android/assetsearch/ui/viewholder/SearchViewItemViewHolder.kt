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

package com.algorand.android.assetsearch.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.databinding.ItemCollectibleSearchViewBinding
import com.algorand.android.models.BaseViewHolder

class SearchViewItemViewHolder(
    private val binding: ItemCollectibleSearchViewBinding,
    private val searchViewTextChangedListener: SearchViewTextChangedListener
) : BaseViewHolder<BaseAssetSearchListItem>(binding.root) {

    override fun bind(item: BaseAssetSearchListItem) {
        if (item !is BaseAssetSearchListItem.SearchViewItem) return
        with(binding.searchView) {
            hint = resources.getString(item.searchViewHintResId)
            setOnTextChanged(searchViewTextChangedListener::onSearchViewTextChanged)
        }
    }

    fun interface SearchViewTextChangedListener {
        fun onSearchViewTextChanged(text: String)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            searchViewTextChangedListener: SearchViewTextChangedListener
        ): SearchViewItemViewHolder {
            val binding = ItemCollectibleSearchViewBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SearchViewItemViewHolder(binding, searchViewTextChangedListener = searchViewTextChangedListener)
        }
    }
}
