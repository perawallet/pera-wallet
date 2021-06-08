/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.assetselector

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation

class AssetSelectorAdapter(
    private val assetSelectorList: List<AssetSelectorBaseItem>,
    private val onAssetClick: (accountCacheData: AccountCacheData, asset: AssetInformation) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    override fun getItemViewType(position: Int): Int {
        return if (assetSelectorList[position] is AssetSelectorBaseItem.AssetSelectorItem) {
            AssetSelectorBaseItem.Type.ASSET_ITEM.ordinal
        } else {
            AssetSelectorBaseItem.Type.HEADER.ordinal
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            AssetSelectorBaseItem.Type.ASSET_ITEM.ordinal -> {
                AssetSelectorViewHolder.create(parent).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            with(assetSelectorList[bindingAdapterPosition] as AssetSelectorBaseItem.AssetSelectorItem) {
                                onAssetClick(accountCacheData, assetInformation)
                            }
                        }
                    }
                }
            }
            AssetSelectorBaseItem.Type.HEADER.ordinal -> AssetSelectorHeaderViewHolder.create(parent)
            else -> throw Exception("Unknown Item View Holder for ${AssetSelectorAdapter::class.java.simpleName}")
        }
    }

    override fun getItemCount() = assetSelectorList.size

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is AssetSelectorHeaderViewHolder -> {
                holder.bind(assetSelectorList[position] as AssetSelectorBaseItem.AssetSelectorHeaderItem)
            }
            is AssetSelectorViewHolder -> {
                holder.bind(assetSelectorList[position] as AssetSelectorBaseItem.AssetSelectorItem)
            }
        }
    }
}
