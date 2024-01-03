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

package com.algorand.android.modules.walletconnect.launchback.multiplebrowser.base.ui.adapter.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.databinding.ItemFallbackBrowserBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.walletconnect.launchback.base.ui.model.LaunchBackBrowserListItem

class LaunchBackBrowserItemViewHolder(
    private val binding: ItemFallbackBrowserBinding,
    private val listener: Listener
) : BaseViewHolder<LaunchBackBrowserListItem>(binding.root) {

    override fun bind(item: LaunchBackBrowserListItem) {
        with(binding) {
            with(item) {
                browserAppCompatImageView.setImageDrawable(ContextCompat.getDrawable(root.context, iconDrawableResId))
                browserNameTextView.text = root.context.getString(nameStringResId)
                root.setOnClickListener { listener.onClick(packageName) }
            }
        }
    }

    fun interface Listener {
        fun onClick(packageName: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): LaunchBackBrowserItemViewHolder {
            val binding = ItemFallbackBrowserBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return LaunchBackBrowserItemViewHolder(binding, listener)
        }
    }
}
