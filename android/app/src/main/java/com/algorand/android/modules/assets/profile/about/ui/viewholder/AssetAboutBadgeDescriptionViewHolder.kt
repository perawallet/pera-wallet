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

import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.databinding.ItemAssetAboutBadgeDescriptionBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.assets.profile.about.ui.model.BaseAssetAboutListItem

class AssetAboutBadgeDescriptionViewHolder(
    private val binding: ItemAssetAboutBadgeDescriptionBinding,
    private val listener: AssetAboutBadgeDescriptionListener
) : BaseViewHolder<BaseAssetAboutListItem>(binding.root) {

    override fun bind(item: BaseAssetAboutListItem) {
        if (item !is BaseAssetAboutListItem.BadgeDescriptionItem) return
        with(binding) {
            asaTierDescriptionLayout.backgroundTintList = ColorStateList.valueOf(
                ContextCompat.getColor(root.context, item.backgroundColorResId)
            )

            asaTierTitleTextView.text = root.context.getString(item.titleTextResId)
            asaTierDescriptionTextView.text = root.context.getString(item.descriptionTextResId)
            ColorStateList.valueOf(ContextCompat.getColor(root.context, item.textColorResId)).run {
                asaTierTitleTextView.setTextColor(this)
                asaTierDescriptionTextView.setTextColor(this)
            }

            asaTierImageView.setImageDrawable(ContextCompat.getDrawable(root.context, item.drawableResId))

            learnMoreAboutButton.setOnClickListener {
                listener.onLearnMoreAsaVerificationClick(item.learnMoreAboutAsaUrl)
            }
        }
    }

    fun interface AssetAboutBadgeDescriptionListener {
        fun onLearnMoreAsaVerificationClick(url: String)
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: AssetAboutBadgeDescriptionListener
        ): AssetAboutBadgeDescriptionViewHolder {
            val binding = ItemAssetAboutBadgeDescriptionBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
            return AssetAboutBadgeDescriptionViewHolder(binding, listener)
        }
    }
}
