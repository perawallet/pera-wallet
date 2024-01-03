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

package com.algorand.android.modules.baseresult.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemResultTitleBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseresult.ui.model.ResultListItem

class ResultTitleViewHolder(
    private val binding: ItemResultTitleBinding
) : BaseViewHolder<ResultListItem>(binding.root) {

    override fun bind(item: ResultListItem) {
        if (item !is ResultListItem.TitleItem) return
        when (item) {
            is ResultListItem.TitleItem.Singular -> bindSingularTitle(item)
            is ResultListItem.TitleItem.Plural -> bindPluralTitle(item)
        }
    }

    private fun bindPluralTitle(item: ResultListItem.TitleItem.Plural) {
        binding.resultTitleTextView.apply {
            text = resources.getQuantityText(item.titleTextResId, item.quantity)
        }
    }

    private fun bindSingularTitle(item: ResultListItem.TitleItem.Singular) {
        binding.resultTitleTextView.setText(item.titleTextResId)
    }

    companion object {
        fun create(parent: ViewGroup): ResultTitleViewHolder {
            val binding = ItemResultTitleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ResultTitleViewHolder(binding)
        }
    }
}
