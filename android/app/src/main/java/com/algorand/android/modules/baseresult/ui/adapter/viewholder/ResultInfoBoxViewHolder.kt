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
import com.algorand.android.databinding.ItemResultInfoBoxBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseresult.ui.model.ResultListItem

class ResultInfoBoxViewHolder(
    private val binding: ItemResultInfoBoxBinding
) : BaseViewHolder<ResultListItem>(binding.root) {

    override fun bind(item: ResultListItem) {
        if (item !is ResultListItem.InfoBoxItem) return
        when (item) {
            is ResultListItem.InfoBoxItem.Singular -> bindSingularInfoBoxItem(item)
            is ResultListItem.InfoBoxItem.Plural -> bindPluralInfoBoxItem(item)
        }
    }

    private fun bindPluralInfoBoxItem(item: ResultListItem.InfoBoxItem.Plural) {
        binding.resultInfoBox.apply {
            setBackgroundTint(item.infoBoxTintColorResId)
            setInfoIcon(item.infoIconResId, item.infoIconTintResId)
            setInfoTitle(item.infoTitleTextResId, item.infoTitleTintResId)
            setInfoDescription(item.infoDescriptionPluralAnnotatedString, item.infoDescriptionTintResId)
        }
    }

    private fun bindSingularInfoBoxItem(item: ResultListItem.InfoBoxItem.Singular) {
        binding.resultInfoBox.apply {
            setBackgroundTint(item.infoBoxTintColorResId)
            setInfoIcon(item.infoIconResId, item.infoIconTintResId)
            setInfoTitle(item.infoTitleTextResId, item.infoTitleTintResId)
            setInfoDescription(item.infoDescriptionAnnotatedString, item.infoDescriptionTintResId)
        }
    }

    companion object {
        fun create(parent: ViewGroup): ResultInfoBoxViewHolder {
            val binding = ItemResultInfoBoxBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ResultInfoBoxViewHolder(binding)
        }
    }
}
