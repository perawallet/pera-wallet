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

package com.algorand.android.banner.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.TextView
import com.algorand.android.databinding.ItemGovernanceBannerBinding
import com.google.android.material.button.MaterialButton

class GovernanceBannerViewHolder(
    private val binding: ItemGovernanceBannerBinding,
    listener: BannerListener
) : BaseBannerViewHolder(listener, binding.root) {

    override val actionButton: MaterialButton
        get() = binding.bannerActionButton
    override val closeButton: MaterialButton
        get() = binding.bannerCloseButton
    override val titleTextView: TextView
        get() = binding.bannerTitleTextView
    override val descriptionTextView: TextView
        get() = binding.bannerDescriptionTextView

    companion object : BannerViewHolderCreator {
        override fun create(listener: BannerListener, parent: ViewGroup): BaseBannerViewHolder {
            val binding = ItemGovernanceBannerBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return GovernanceBannerViewHolder(binding, listener)
        }
    }
}
