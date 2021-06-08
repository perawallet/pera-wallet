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

package com.algorand.android.ui.common.listhelper.viewholders

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.view.isGone
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountAssetBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetStatus
import com.algorand.android.ui.common.listhelper.BaseAccountListItem

class AssetItemViewHolder(
    private val binding: ItemAccountAssetBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(assetListItem: AssetListItem) {
        with(assetListItem.assetInformation) {
            setBackground(assetListItem.roundedCornerNeeded)
            setName(this)
            setBalance(this)
            setPendingUI(assetStatus)
        }
    }

    private fun setPendingUI(assetStatus: AssetStatus) {
        val isPending = assetStatus != AssetStatus.OWNED_BY_ACCOUNT

        if (isPending) {
            binding.statusTextView.setText(
                if (assetStatus == AssetStatus.PENDING_FOR_REMOVAL) {
                    R.string.removing_asset
                } else {
                    R.string.adding_asset
                }
            )

            binding.statusTextView.visibility = View.VISIBLE
            binding.pendingImageView.visibility = View.VISIBLE
        } else {
            binding.pendingImageView.visibility = View.GONE
            binding.statusTextView.visibility = View.GONE
            binding.nameTextView.alpha = FULL_VISIBLE_ALPHA
        }
    }

    private fun setBalance(assetInformation: AssetInformation) {
        val isPending = assetInformation.assetStatus != AssetStatus.OWNED_BY_ACCOUNT

        if (isPending) {
            binding.balanceTextView.visibility = View.GONE
        } else {
            binding.balanceTextView.apply {
                text = assetInformation.formattedAmount
                visibility = View.VISIBLE
            }
        }
    }

    private fun setName(assetInformation: AssetInformation) {
        val isPending = assetInformation.assetStatus != AssetStatus.OWNED_BY_ACCOUNT

        binding.nameTextView.apply {
            setupUI(assetInformation)
            alpha = if (isPending) PENDING_ALPHA else FULL_VISIBLE_ALPHA
        }
    }

    private fun setBackground(roundedCornerNeeded: Boolean) {
        itemView.setBackgroundResource(
            if (roundedCornerNeeded) {
                R.drawable.bg_asset_bottom_item_rippled
            } else {
                R.drawable.bg_asset_middle_item_rippled
            }
        )
        binding.dividerView.isGone = roundedCornerNeeded
    }

    companion object {
        private const val PENDING_ALPHA = 0.4f
        private const val FULL_VISIBLE_ALPHA = 1f

        fun create(parent: ViewGroup): AssetItemViewHolder {
            val binding = ItemAccountAssetBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AssetItemViewHolder(binding)
        }
    }
}

data class AssetListItem(
    val publicKey: String,
    val accountName: String,
    val assetInformation: AssetInformation,
    val roundedCornerNeeded: Boolean
) : BaseAccountListItem()
