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

package com.algorand.android.ui.send.assetselection.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.doOnLayout
import com.algorand.android.databinding.ItemSelectCollectibleBinding
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.models.BaseViewHolder

abstract class BaseSelectCollectibleItemViewHolder(
    private val binding: ItemSelectCollectibleBinding,
    private val listener: SelectCollectibleItemListener
) : BaseViewHolder<BaseSelectAssetItem>(binding.root) {

    protected open fun bindImage(item: BaseSelectAssetItem.BaseSelectCollectibleItem) {
        binding.collectibleItemView.apply {
            setStartIconDrawable(drawable = null, forceShow = true)
            getStartIconImageView().doOnLayout {
                item.baseAssetDrawableProvider.provideAssetDrawable(
                    context = context,
                    assetName = item.avatarDisplayText,
                    logoUri = item.prismUrl,
                    width = it.measuredWidth,
                    onResourceReady = ::setStartIconDrawable
                )
            }
        }
    }

    override fun bind(item: BaseSelectAssetItem) {
        if (item !is BaseSelectAssetItem.BaseSelectCollectibleItem) return
        with(item) {
            with(binding.collectibleItemView) {
                setTitleText(name)
                setDescriptionText(shortName)
                setPrimaryValueText(formattedCompactAmount)
                setSecondaryValueText(
                    if (isAmountInSelectedCurrencyVisible) formattedSelectedCurrencyCompactValue else null
                )
                bindImage(item)
                setOnClickListener { listener.onCollectibleItemClick(item.id) }
            }
        }
    }

    fun interface SelectCollectibleItemListener {
        fun onCollectibleItemClick(assetId: Long)
    }

    protected interface SelectCollectibleItemViewHolderCreator {
        fun create(
            parent: ViewGroup,
            listener: SelectCollectibleItemListener
        ): BaseSelectCollectibleItemViewHolder
    }

    companion object {
        fun createItemSelectCollectibleBinding(
            parent: ViewGroup
        ): ItemSelectCollectibleBinding {
            return ItemSelectCollectibleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        }
    }
}
