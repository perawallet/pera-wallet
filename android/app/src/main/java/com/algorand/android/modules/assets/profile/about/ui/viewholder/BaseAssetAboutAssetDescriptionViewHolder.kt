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

package com.algorand.android.modules.assets.profile.about.ui.viewholder

import android.view.ViewGroup
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.ItemAssetAboutAssetDescriptionBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem
import kotlin.properties.Delegates

abstract class BaseAssetAboutAssetDescriptionViewHolder(
    private val binding: ItemAssetAboutAssetDescriptionBinding
) : BaseViewHolder<BaseAssetAboutListItem>(binding.root) {

    private val descriptionLinesCountLimit = binding.root.resources.getInteger(
        R.integer.asset_description_max_lines_count
    )

    private var isExpanded by Delegates.observable(false) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            if (newValue) expandDescriptionTextView() else collapseDescriptionTextView()
        }
    }

    override fun bind(item: BaseAssetAboutListItem) {
        binding.descriptionTextView.apply {
            post {
                maxLines = if (lineCount > descriptionLinesCountLimit) descriptionLinesCountLimit else Int.MAX_VALUE
                binding.showMoreButton.apply {
                    isVisible = binding.descriptionTextView.lineCount > descriptionLinesCountLimit
                    setOnClickListener { isExpanded = !isExpanded }
                }
            }
        }
    }

    private fun expandDescriptionTextView() {
        with(binding) {
            descriptionTextView.maxLines = Int.MAX_VALUE
            showMoreButton.setText(R.string.show_less)
        }
    }

    private fun collapseDescriptionTextView() {
        with(binding) {
            descriptionTextView.maxLines = descriptionLinesCountLimit
            showMoreButton.setText(R.string.show_more)
        }
    }

    protected interface BaseAssetAboutAssetDescriptionViewHolderItemViewHolderCreator {
        fun create(parent: ViewGroup): BaseAssetAboutAssetDescriptionViewHolder
    }
}
