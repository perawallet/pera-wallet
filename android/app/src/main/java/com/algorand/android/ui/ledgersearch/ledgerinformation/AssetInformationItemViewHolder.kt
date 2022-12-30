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

package com.algorand.android.ui.ledgersearch.ledgerinformation

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemLedgerInformationAssetBinding
import com.algorand.android.models.LedgerInformationListItem

class AssetInformationItemViewHolder(
    private val binding: ItemLedgerInformationAssetBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(assetInformationItem: LedgerInformationListItem.AssetInformationItem) {
        with(assetInformationItem) {
            with(binding.assetItemView) {
                getStartIconImageView().apply {
                    baseAssetDrawableProvider.provideAssetDrawable(
                        imageView = this,
                        onResourceFailed = ::setStartIconDrawable
                    )
                }
                setTitleText(name.getName(resources))
                setDescriptionText(shortName.getName(resources))
                setPrimaryValueText(formattedAmount)
                setSecondaryValueText(if (isAmountInDisplayedCurrencyVisible) formattedDisplayedCurrencyValue else null)
                setTitleTextColor(verificationTierConfiguration.textColorResId)
                setTrailingIconOfTitleText(verificationTierConfiguration.drawableResId)
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): AssetInformationItemViewHolder {
            val binding = ItemLedgerInformationAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetInformationItemViewHolder(binding)
        }
    }
}
