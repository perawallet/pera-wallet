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

package com.algorand.android.ui.accountdetail.assets.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.AccountDetailAssetsItem.BaseAssetItem
import com.algorand.android.models.BaseDiffUtil

class AccountAssetsAdapter(
    private val listener: Listener
) : ListAdapter<AccountDetailAssetsItem, RecyclerView.ViewHolder>(BaseDiffUtil()) {

    private val searchViewItemListener = object : SearchViewViewHolder.Listener {
        override fun onSearchQueryChanged(query: String) {
            listener.onSearchQueryUpdated(query)
        }

        override fun onClick() {
            listener.onSearchViewClick()
        }
    }

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            AccountDetailAssetsItem.AssetAdditionItem -> R.layout.item_asset_addition
            AccountDetailAssetsItem.SearchViewItem -> R.layout.item_search_asset
            is BaseAssetItem.OwnedAssetItem -> R.layout.item_account_asset_view
            is BaseAssetItem.BasePendingAssetItem -> R.layout.item_account_pending_asset_view
            is AccountDetailAssetsItem.AccountValueItem -> R.layout.item_account_value
            is AccountDetailAssetsItem.TitleItem -> R.layout.item_account_title
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            R.layout.item_asset_addition -> createAssetAdditionViewHolder(parent)
            R.layout.item_search_asset -> createAssetSearchItemViewHolder(parent)
            R.layout.item_account_value -> createAccountValueViewHolder(parent)
            R.layout.item_account_asset_view -> createOwnedAssetViewHolder(parent)
            R.layout.item_account_title -> createTitleViewHolder(parent)
            R.layout.item_account_pending_asset_view -> createPendingAssetViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Item View Type is Unknown.")
        }
    }

    private fun createAssetAdditionViewHolder(parent: ViewGroup): AssetAdditionViewHolder {
        return AssetAdditionViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onAddNewAssetClick()
                }
            }
        }
    }

    private fun createAssetSearchItemViewHolder(parent: ViewGroup): SearchViewViewHolder {
        return SearchViewViewHolder.create(parent, searchViewItemListener)
    }

    private fun createAccountValueViewHolder(parent: ViewGroup): AccountValueViewHolder {
        return AccountValueViewHolder.create(parent)
    }

    private fun createOwnedAssetViewHolder(parent: ViewGroup): OwnedAssetViewHolder {
        return OwnedAssetViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    listener.onAssetClick(getItem(bindingAdapterPosition) as BaseAssetItem)
                }
            }
        }
    }

    private fun createPendingAssetViewHolder(parent: ViewGroup): PendingAssetViewHolder {
        return PendingAssetViewHolder.create(parent)
    }

    private fun createTitleViewHolder(parent: ViewGroup): TitleViewHolder {
        return TitleViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (holder) {
            is AssetAdditionViewHolder -> return
            is SearchViewViewHolder -> holder.bind(getItem(position) as AccountDetailAssetsItem.SearchViewItem)
            is AccountValueViewHolder -> holder.bind(getItem(position) as AccountDetailAssetsItem.AccountValueItem)
            is OwnedAssetViewHolder -> holder.bind(getItem(position) as BaseAssetItem.OwnedAssetItem)
            is TitleViewHolder -> holder.bind(getItem(position) as AccountDetailAssetsItem.TitleItem)
            is PendingAssetViewHolder -> holder.bind(getItem(position) as BaseAssetItem.BasePendingAssetItem)
            else -> throw IllegalArgumentException("$logTag : Item View Type is Unknown.")
        }
    }

    interface Listener {
        fun onSearchQueryUpdated(query: String) {}
        fun onAssetClick(assetItem: BaseAssetItem)
        fun onAddNewAssetClick() {}
        fun onSearchViewClick() {}
    }

    companion object {
        private val logTag = AccountAssetsAdapter::class.java.simpleName
    }
}
