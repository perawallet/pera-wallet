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

package com.algorand.android.modules.swap.assetselection.base

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemSwapAssetSelectionBinding
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionItem

class SwapAssetSelectionViewHolder(
    private val binding: ItemSwapAssetSelectionBinding,
    private val listener: SwapAssetSelectionViewHolderListener
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: SwapAssetSelectionItem) {
        with(binding.assetItemView) {
            rootView.setOnClickListener { listener.onAssetItemSelected(item) }
            setTitleText(item.assetFullName.getName(resources))
            setTrailingIconOfTitleText(item.verificationTier.drawableResId)
            setDescriptionText(item.assetShortName.getName(resources))
            setPrimaryValueText(item.formattedPrimaryValue, item.arePrimaryAndSecondaryValueVisible)
            setSecondaryValueText(item.formattedSecondaryValue, item.arePrimaryAndSecondaryValueVisible)
            getStartIconImageView().apply {
                item.assetDrawableProvider.provideAssetDrawable(
                    imageView = this,
                    onResourceFailed = ::setStartIconDrawable
                )
            }
        }
    }

    interface SwapAssetSelectionViewHolderListener {
        fun onAssetItemSelected(item: SwapAssetSelectionItem)
    }

    companion object {
        fun create(parent: ViewGroup, listener: SwapAssetSelectionViewHolderListener): SwapAssetSelectionViewHolder {
            val binding = ItemSwapAssetSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SwapAssetSelectionViewHolder(binding, listener)
        }
    }
}
