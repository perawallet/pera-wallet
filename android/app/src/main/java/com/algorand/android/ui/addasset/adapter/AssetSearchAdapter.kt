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

package com.algorand.android.ui.addasset.adapter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.ui.addasset.AssetQueryItemDiffUtil

class AssetSearchAdapter(
    private val onAssetClick: (asset: AssetQueryItem) -> Unit
) : PagingDataAdapter<AssetQueryItem, AssetSearchItemViewHolder>(AssetQueryItemDiffUtil()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AssetSearchItemViewHolder {
        return AssetSearchItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { assetQueryItem ->
                        onAssetClick(assetQueryItem)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: AssetSearchItemViewHolder, position: Int) {
        getItem(position)?.let { assetQueryItem ->
            holder.bind(assetQueryItem)
        }
    }
}
