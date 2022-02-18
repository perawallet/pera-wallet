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

package com.algorand.android.ui.send.assetselection.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetSelection
import com.algorand.android.models.BaseDiffUtil

class AssetSelectionAdapter(
    private val onAssetClick: (AssetInformation) -> Unit
) : ListAdapter<AssetSelection, AssetSelectionViewHolder>(BaseDiffUtil()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AssetSelectionViewHolder {
        return AssetSelectionViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).assetInformation.let(onAssetClick)
                }
            }
        }
    }

    override fun onBindViewHolder(holder: AssetSelectionViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
}
