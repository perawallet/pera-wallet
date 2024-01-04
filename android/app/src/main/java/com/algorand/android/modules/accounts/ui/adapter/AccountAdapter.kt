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

package com.algorand.android.modules.accounts.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.banner.ui.viewholder.BackupBannerViewHolder
import com.algorand.android.banner.ui.viewholder.BaseBannerViewHolder
import com.algorand.android.banner.ui.viewholder.GenericBannerViewHolder
import com.algorand.android.banner.ui.viewholder.GovernanceBannerViewHolder
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.ACCOUNT_ERROR
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.ACCOUNT_SUCCESS
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.BACKUP_BANNER
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.GENERIC_BANNER
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.GOVERNANCE_BANNER
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.HEADER
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.ItemType.QUICK_ACTIONS
import com.algorand.android.modules.accounts.ui.viewholder.AccountErrorItemViewHolder
import com.algorand.android.modules.accounts.ui.viewholder.AccountItemViewHolder
import com.algorand.android.modules.accounts.ui.viewholder.AccountsQuickActionsViewHolder
import com.algorand.android.modules.accounts.ui.viewholder.HeaderViewHolder

class AccountAdapter(
    private val accountAdapterListener: AccountAdapterListener
) : ListAdapter<BaseAccountListItem, BaseViewHolder<BaseAccountListItem>>(BaseDiffUtil<BaseAccountListItem>()) {

    private val accountClickListener = object : AccountItemViewHolder.AccountClickListener {
        override fun onAccountClick(publicKey: String) {
            accountAdapterListener.onSucceedAccountClick(publicKey)
        }

        override fun onAccountLongPress(publicKey: String) {
            accountAdapterListener.onAccountItemLongPressed(publicKey)
        }
    }

    private val accountErrorClickListener = object : AccountErrorItemViewHolder.AccountClickListener {
        override fun onAccountClick(publicKey: String) {
            accountAdapterListener.onFailedAccountClick(publicKey)
        }

        override fun onAccountLongPress(publicKey: String) {
            accountAdapterListener.onAccountItemLongPressed(publicKey)
        }
    }

    private val optionsClickListener = object : HeaderViewHolder.OptionsClickListener {
        override fun onSortClick() {
            accountAdapterListener.onSortClick()
        }

        override fun onAddAccountClick() {
            accountAdapterListener.onAddAccountClick()
        }
    }

    private val baseBannerListener = object : BaseBannerViewHolder.BannerListener {
        override fun onActionButtonClick(url: String) {
            accountAdapterListener.onBannerActionButtonClick(url = url, isGovernance = false)
        }

        override fun onCloseBannerClick(bannerId: Long) {
            accountAdapterListener.onBannerCloseButtonClick(bannerId)
        }
    }

    private val governanceBaseBannerListener = object : BaseBannerViewHolder.BannerListener {
        override fun onActionButtonClick(url: String) {
            accountAdapterListener.onBannerActionButtonClick(url = url, isGovernance = true)
        }

        override fun onCloseBannerClick(bannerId: Long) {
            accountAdapterListener.onBannerCloseButtonClick(bannerId)
        }
    }

    private val backupBannerListener = object : BackupBannerViewHolder.Listener {
        override fun onActionButtonClick() {
            accountAdapterListener.onBackupBannerActionButtonClick()
        }
    }

    private val accountsQuickActionsListener = object : AccountsQuickActionsViewHolder.AccountsQuickActionsListener {
        override fun onBuySellClick() {
            accountAdapterListener.onBuySellClick()
        }

        override fun onSendClick() {
            accountAdapterListener.onSendClick()
        }

        override fun onSwapClick() {
            accountAdapterListener.onSwapClick()
        }

        override fun onScanQrClick() {
            accountAdapterListener.onScanQrClick()
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAccountListItem> {
        return when (viewType) {
            HEADER.ordinal -> HeaderViewHolder.create(parent, optionsClickListener)
            ACCOUNT_SUCCESS.ordinal -> AccountItemViewHolder.create(parent, accountClickListener)
            ACCOUNT_ERROR.ordinal -> AccountErrorItemViewHolder.create(parent, accountErrorClickListener)
            GOVERNANCE_BANNER.ordinal -> GovernanceBannerViewHolder.create(governanceBaseBannerListener, parent)
            GENERIC_BANNER.ordinal -> GenericBannerViewHolder.create(baseBannerListener, parent)
            BACKUP_BANNER.ordinal -> BackupBannerViewHolder.create(parent, backupBannerListener)
            QUICK_ACTIONS.ordinal -> AccountsQuickActionsViewHolder.create(parent, accountsQuickActionsListener)
            else -> throw Exception("$logTag: Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAccountListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface AccountAdapterListener {
        fun onSucceedAccountClick(publicKey: String)
        fun onFailedAccountClick(publicKey: String)
        fun onAccountItemLongPressed(publicKey: String)
        fun onBannerCloseButtonClick(bannerId: Long)
        fun onBannerActionButtonClick(url: String, isGovernance: Boolean)
        fun onBackupBannerActionButtonClick()
        fun onBuySellClick()
        fun onSendClick()
        fun onSwapClick()
        fun onScanQrClick()
        fun onSortClick()
        fun onAddAccountClick()
    }

    companion object {
        private val logTag = AccountAdapter::class.java.simpleName
    }
}
