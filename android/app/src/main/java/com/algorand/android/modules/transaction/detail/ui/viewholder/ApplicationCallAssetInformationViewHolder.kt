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

package com.algorand.android.modules.transaction.detail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemApplicationCallAssetInformationBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.BaseApplicationCallAssetInformationListItem

class ApplicationCallAssetInformationViewHolder(
    private val binding: ItemApplicationCallAssetInformationBinding
) : BaseViewHolder<BaseApplicationCallAssetInformationListItem>(binding.root) {

    override fun bind(item: BaseApplicationCallAssetInformationListItem) {
        if (item !is BaseApplicationCallAssetInformationListItem.AssetInformationItem) return
        with(item.assetItemConfiguration) {
            with(binding.root) {
                setAssetTitleText(accountTitleText = primaryAssetName?.getName(resources))
                setAssetDescriptionText(
                    assetShortName = secondaryAssetName?.getName(resources),
                    assetId = assetId
                )
            }
        }
    }

    private fun setAssetTitleText(accountTitleText: String?) {
        binding.assetItemView.setTitleText(accountTitleText)
    }

    private fun setAssetDescriptionText(assetShortName: String?, assetId: Long) {
        binding.assetItemView.apply {
            val descriptionText = resources.getString(
                R.string.pair_value_format_with_coma,
                assetShortName,
                assetId
            )
            binding.assetItemView.setDescriptionText(descriptionText)
        }
    }

    companion object {
        fun create(parent: ViewGroup): ApplicationCallAssetInformationViewHolder {
            val binding =
                ItemApplicationCallAssetInformationBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return ApplicationCallAssetInformationViewHolder(binding)
        }
    }
}
