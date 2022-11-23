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

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.AccountDetailAssetsItem.BaseAssetItem
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.ACCOUNT_PORTFOLIO
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.ASSET
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.ASSETS_LIST_TITLE
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.NO_ASSET_FOUND
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.PENDING_ASSET
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.QUICK_ACTIONS
import com.algorand.android.models.AccountDetailAssetsItem.ItemType.SEARCH
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountDetailAssetsTitleViewHolder.AccountDetailAssetsTitleViewHolderListener
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountDetailQuickActionsViewHolder.AccountDetailQuickActionsListener
import com.algorand.android.utils.hideKeyboard

class AccountAssetsAdapter(
    private val listener: Listener
) : ListAdapter<AccountDetailAssetsItem, BaseViewHolder<AccountDetailAssetsItem>>(BaseDiffUtil()) {

    private val searchViewItemListener = object : SearchViewViewHolder.Listener {
        override fun onSearchQueryChanged(query: String) {
            listener.onSearchQueryUpdated(query)
        }
    }

    private val quickActionsViewHolderListener = object : AccountDetailQuickActionsListener {
        override fun onBuyAlgoClick() {
            listener.onBuyAlgoClick()
        }

        override fun onSendClick() {
            listener.onSendClick()
        }

        override fun onSwapClick() {
            listener.onSwapClick()
        }

        override fun onMoreClick() {
            listener.onMoreClick()
        }
    }

    private val assetsTitleViewHolderListener = object : AccountDetailAssetsTitleViewHolderListener {
        override fun onManageAssetsClick() {
            listener.onManageAssetsClick()
        }

        override fun onAddAssetClick() {
            listener.onAddNewAssetClick()
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<AccountDetailAssetsItem> {
        return when (viewType) {
            SEARCH.ordinal -> createAssetSearchItemViewHolder(parent)
            ACCOUNT_PORTFOLIO.ordinal -> createAccountValueViewHolder(parent)
            ASSET.ordinal -> createOwnedAssetViewHolder(parent)
            ASSETS_LIST_TITLE.ordinal -> createAssetTitleViewHolder(parent)
            PENDING_ASSET.ordinal -> createPendingAssetViewHolder(parent)
            QUICK_ACTIONS.ordinal -> createQuickActionsViewHolder(parent)
            NO_ASSET_FOUND.ordinal -> createNoAssetFoundScreenStateViewHolder(parent)
            else -> throw IllegalArgumentException("$logTag : Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<AccountDetailAssetsItem>, position: Int) {
        holder.bind(getItem(position))
    }

    override fun onViewDetachedFromWindow(holder: BaseViewHolder<AccountDetailAssetsItem>) {
        super.onViewDetachedFromWindow(holder)
        if (holder is SearchViewViewHolder) {
            holder.itemView.hideKeyboard()
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

    private fun createAssetTitleViewHolder(parent: ViewGroup): AccountDetailAssetsTitleViewHolder {
        return AccountDetailAssetsTitleViewHolder.create(parent, assetsTitleViewHolderListener)
    }

    private fun createQuickActionsViewHolder(parent: ViewGroup): AccountDetailQuickActionsViewHolder {
        return AccountDetailQuickActionsViewHolder.create(parent, quickActionsViewHolderListener)
    }

    private fun createNoAssetFoundScreenStateViewHolder(parent: ViewGroup): NoAssetFoundScreenStateViewHolder {
        return NoAssetFoundScreenStateViewHolder.create(parent)
    }

    interface Listener {
        fun onSearchQueryUpdated(query: String) {}
        fun onAssetClick(assetItem: BaseAssetItem)
        fun onAddNewAssetClick() {}
        fun onManageAssetsClick()
        fun onBuyAlgoClick()
        fun onSendClick()
        fun onSwapClick()
        fun onMoreClick()
    }

    companion object {
        private val logTag = AccountAssetsAdapter::class.java.simpleName
    }
}
