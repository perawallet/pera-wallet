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
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountDetailAssetsTitleViewHolder.AccountDetailAssetsTitleViewHolderListener
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountDetailQuickActionsViewHolder.AccountDetailQuickActionsListener
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.ACCOUNT_PORTFOLIO
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.ASSET
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.ASSETS_LIST_TITLE
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.NFT
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.NO_ASSET_FOUND
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.PENDING_ASSET
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.PENDING_NFT
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.QUICK_ACTIONS
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.REQUIRED_MINIMUM_BALANCE
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.ItemType.SEARCH
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
        override fun onBuySellClick() {
            listener.onBuySellClick()
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

        override fun onCopyAddressClick() {
            listener.onCopyAddressClick()
        }

        override fun onShowAddressClick() {
            listener.onShowAddressClick()
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

    private val requiredMinimumBalanceListener = RequiredMinimumBalanceItemViewHolder.RequiredMinimumBalanceListener {
        listener.onRequiredMinimumBalanceClick()
    }

    private val ownedAssetViewHolderListener = object : OwnedAssetViewHolder.Listener {
        override fun onOwnedAssetItemClick(assetId: Long) {
            listener.onAssetClick(assetId)
        }

        override fun onOwnedAssetLongPressed(assetId: Long) {
            listener.onAssetLongClick(assetId)
        }
    }

    private val ownedNFTViewHolderListener = object : OwnedNFTViewHolder.Listener {
        override fun onOwnedNFTItemClick(nftId: Long) {
            listener.onNFTClick(nftId)
        }

        override fun onOwnedNFTItemLongPressed(nftId: Long) {
            listener.onNFTLongClick(nftId)
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
            REQUIRED_MINIMUM_BALANCE.ordinal -> createRequiredMinimumBalanceViewHolder(parent)
            NFT.ordinal -> createOwnedNFTViewHolder(parent)
            PENDING_NFT.ordinal -> createPendingNFTViewHolder(parent)
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
        return OwnedAssetViewHolder.create(parent, ownedAssetViewHolderListener)
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

    private fun createRequiredMinimumBalanceViewHolder(parent: ViewGroup): RequiredMinimumBalanceItemViewHolder {
        return RequiredMinimumBalanceItemViewHolder.create(parent, requiredMinimumBalanceListener)
    }

    private fun createOwnedNFTViewHolder(parent: ViewGroup): OwnedNFTViewHolder {
        return OwnedNFTViewHolder.create(parent, ownedNFTViewHolderListener)
    }

    private fun createPendingNFTViewHolder(parent: ViewGroup): PendingNFTViewHolder {
        return PendingNFTViewHolder.create(parent)
    }

    interface Listener {
        fun onSearchQueryUpdated(query: String) {}
        fun onAssetClick(assetId: Long)
        fun onAssetLongClick(assetId: Long)
        fun onNFTClick(nftId: Long)
        fun onNFTLongClick(nftId: Long)
        fun onAddNewAssetClick() {}
        fun onManageAssetsClick()
        fun onBuySellClick()
        fun onSendClick()
        fun onSwapClick()
        fun onMoreClick()
        fun onRequiredMinimumBalanceClick()
        fun onCopyAddressClick()
        fun onShowAddressClick()
    }

    companion object {
        private val logTag = AccountAssetsAdapter::class.java.simpleName
    }
}
