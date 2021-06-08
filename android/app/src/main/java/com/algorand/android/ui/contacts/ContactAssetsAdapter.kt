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

package com.algorand.android.ui.contacts

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.AssetInformation

class ContactAssetsAdapter(
    private val onSendButtonClick: (assetInformation: AssetInformation) -> Unit
) : RecyclerView.Adapter<ContactAssetViewHolder>() {

    private val algorandAssetInformation = AssetInformation.getAlgorandAsset()
    private val assetsList = mutableListOf(algorandAssetInformation)

    fun setAssets(assetsInformation: List<AssetInformation>) {
        assetsList.clear()
        assetsList.addAll(assetsInformation)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        ContactAssetViewHolder.create(parent).apply {
            binding.sendButton.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    onSendButtonClick(assetsList[bindingAdapterPosition])
                }
            }
        }

    override fun getItemCount() = assetsList.size

    override fun onBindViewHolder(holder: ContactAssetViewHolder, position: Int) {
        holder.bind(assetsList[position])
    }
}
