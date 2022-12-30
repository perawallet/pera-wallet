/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.assets.remove.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.databinding.ItemScreenStateViewBinding
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.BaseViewHolder

class ScreenStateViewHolder(
    private val binding: ItemScreenStateViewBinding
) : BaseViewHolder<BaseRemoveAssetItem>(binding.root) {

    override fun bind(item: BaseRemoveAssetItem) {
        if (item !is BaseRemoveAssetItem.ScreenStateItem) return
        binding.root.apply {
            updateLayoutParams<ViewGroup.MarginLayoutParams> {
                setMargins(0, resources.getDimensionPixelSize(R.dimen.spacing_xxxxlarge), 0, 0)
            }
        }
        binding.screenStateView.setupUi(item.screenState)
    }

    companion object {
        fun create(parent: ViewGroup): ScreenStateViewHolder {
            val binding = ItemScreenStateViewBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ScreenStateViewHolder(binding)
        }
    }
}
