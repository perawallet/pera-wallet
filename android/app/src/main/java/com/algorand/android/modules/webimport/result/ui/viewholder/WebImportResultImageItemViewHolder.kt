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

package com.algorand.android.modules.webimport.result.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemImageSimpleBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.webimport.result.ui.model.BaseAccountResultListItem

class WebImportResultImageItemViewHolder(
    private val binding: ItemImageSimpleBinding
) : BaseViewHolder<BaseAccountResultListItem>(binding.root) {

    override fun bind(item: BaseAccountResultListItem) {
        if (item !is BaseAccountResultListItem.ImageItem) return
        binding.imageView.apply {
            setImageResource(item.drawableResId)
            item.drawableTintResId?.let { imageTintList = context.getColorStateList(it) }
        }
    }

    companion object {
        fun create(parent: ViewGroup): WebImportResultImageItemViewHolder {
            val binding =
                ItemImageSimpleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return WebImportResultImageItemViewHolder(binding)
        }
    }
}
