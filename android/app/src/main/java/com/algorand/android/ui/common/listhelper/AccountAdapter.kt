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

package com.algorand.android.ui.common.listhelper

import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.customviews.Tooltip
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.ui.common.listhelper.viewholders.AddAssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.AddAssetViewHolder
import com.algorand.android.ui.common.listhelper.viewholders.AssetItemViewHolder
import com.algorand.android.ui.common.listhelper.viewholders.AssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.HeaderAccountListItem
import com.algorand.android.ui.common.listhelper.viewholders.HeaderViewHolder
import com.algorand.android.ui.common.listhelper.viewholders.RemoveAssetItemViewHolder
import com.algorand.android.ui.common.listhelper.viewholders.RemoveAssetListItem
import com.google.android.material.button.MaterialButton

// TODO move this methods to listener
class AccountAdapter(
    private val onShowQrClick: ((String, String) -> Unit)? = null,
    private val onAccountOptionsClick: ((String, String, Account.Type?) -> Unit)? = null,
    private val onAssetClick: ((String, AssetInformation) -> Unit)? = null,
    private val onAddAssetClick: ((String) -> Unit)? = null,
    private val onRemoveAssetClick: ((String, AssetInformation) -> Unit)? = null,
    private var showQRTutorial: Boolean = false
) : ListAdapter<BaseAccountListItem, RecyclerView.ViewHolder>(BaseAccountListItem.BaseAccountListDiffUtil()) {

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is HeaderAccountListItem -> BaseAccountListItem.ItemType.HEADER.ordinal
            is AssetListItem -> BaseAccountListItem.ItemType.ASSET.ordinal
            is AddAssetListItem -> BaseAccountListItem.ItemType.ADD_ASSET.ordinal
            is RemoveAssetListItem -> BaseAccountListItem.ItemType.REMOVE_ASSET.ordinal
            else -> throw Exception("AccountAdapter: List Item is Unknown.")
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            BaseAccountListItem.ItemType.HEADER.ordinal -> {
                HeaderViewHolder.create(parent).apply {
                    if (onAccountOptionsClick != null) {
                        binding.optionsButton.setOnClickListener {
                            if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                                (getItem(bindingAdapterPosition) as HeaderAccountListItem).accountCacheData.run {
                                    onAccountOptionsClick.invoke(account.name, account.address, account.type)
                                }
                            }
                        }
                        binding.optionsButton.visibility = View.VISIBLE
                    }

                    if (onShowQrClick != null) {
                        binding.qrButton.apply {
                            setOnClickListener {
                                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                                    (getItem(bindingAdapterPosition) as HeaderAccountListItem).accountCacheData.run {
                                        onShowQrClick.invoke(account.address, account.name)
                                    }
                                }
                            }
                            visibility = View.VISIBLE

                            if (showQRTutorial) {
                                showQrTutorialTooltip(binding.qrButton)
                            }
                        }
                    }
                }
            }
            BaseAccountListItem.ItemType.ADD_ASSET.ordinal -> {
                AddAssetViewHolder.create(parent).apply {
                    binding.addAssetButton.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            onAddAssetClick?.invoke((getItem(bindingAdapterPosition) as AddAssetListItem).publicKey)
                        }
                    }
                }
            }
            BaseAccountListItem.ItemType.ASSET.ordinal -> {
                AssetItemViewHolder.create(parent).apply {
                    itemView.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            (getItem(bindingAdapterPosition) as AssetListItem).run {
                                onAssetClick?.invoke(publicKey, assetInformation)
                            }
                        }
                    }
                }
            }
            BaseAccountListItem.ItemType.REMOVE_ASSET.ordinal -> {
                RemoveAssetItemViewHolder.create(parent).apply {
                    binding.removeAssetButton.setOnClickListener {
                        if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                            (getItem(bindingAdapterPosition) as RemoveAssetListItem).run {
                                onRemoveAssetClick?.invoke(publicKey, assetInformation)
                            }
                        }
                    }
                }
            }
            else -> throw Exception("Account Adapter: Item View Type is Unknown.")
        }
    }

    private fun showQrTutorialTooltip(showQrButton: MaterialButton) {
        showQRTutorial = false
        with(showQrButton) {
            post {
                val endMargin = resources.getDimensionPixelSize(R.dimen.page_horizontal_spacing)
                val config = Tooltip.Config(this, endMargin, R.string.your_accounts_address, false)
                Tooltip(context).show(config)
            }
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is HeaderViewHolder -> {
                holder.bind(getItem(position) as HeaderAccountListItem)
            }
            is AssetItemViewHolder -> {
                holder.bind(getItem(position) as AssetListItem)
            }
            is RemoveAssetItemViewHolder -> {
                holder.bind(getItem(position) as RemoveAssetListItem, itemCount != position + 1)
            }
        }
    }
}
