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

import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.databinding.ItemResultIconBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.baseresult.ui.model.ResultListItem

class ResultIconViewHolder(
    private val binding: ItemResultIconBinding
) : BaseViewHolder<ResultListItem>(binding.root) {

    override fun bind(item: ResultListItem) {
        if (item !is ResultListItem.IconItem) return
        binding.resultIconImageView.apply {
            setImageResource(item.iconResId)
            imageTintList = ColorStateList.valueOf(ContextCompat.getColor(context, item.iconTintColorResId))
        }
    }

    companion object {
        fun create(parent: ViewGroup): ResultIconViewHolder {
            val binding = ItemResultIconBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ResultIconViewHolder(binding)
        }
    }
}
