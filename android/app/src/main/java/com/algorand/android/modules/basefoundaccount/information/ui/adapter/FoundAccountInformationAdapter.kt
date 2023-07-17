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

package com.algorand.android.modules.basefoundaccount.information.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.adapter.viewholder.FoundAccountInformationAccountViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.adapter.viewholder.FoundAccountInformationAssetViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.adapter.viewholder.FoundAccountInformationTitleViewHolder
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem

class FoundAccountInformationAdapter(
    private val listener: Listener
) : ListAdapter<BaseFoundAccountInformationItem, BaseViewHolder<BaseFoundAccountInformationItem>>(BaseDiffUtil()) {

    private val accountViewHolderListener = FoundAccountInformationAccountViewHolder.Listener { accountAddress ->
        listener.onAccountItemLongClick(accountAddress)
    }

    private val assetViewHolderListener = FoundAccountInformationAssetViewHolder.Listener { assetId ->
        listener.onAssetItemLongClick(assetId)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseFoundAccountInformationItem> {
        return when (viewType) {
            BaseFoundAccountInformationItem.ItemType.ACCOUNT_ITEM.ordinal -> createAccountViewHolder(parent)
            BaseFoundAccountInformationItem.ItemType.ASSET_ITEM.ordinal -> createAssetViewHolder(parent)
            BaseFoundAccountInformationItem.ItemType.TITLE_ITEM.ordinal -> createTitleViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createTitleViewHolder(parent: ViewGroup): FoundAccountInformationTitleViewHolder {
        return FoundAccountInformationTitleViewHolder.create(parent)
    }

    private fun createAccountViewHolder(parent: ViewGroup): FoundAccountInformationAccountViewHolder {
        return FoundAccountInformationAccountViewHolder.create(parent, accountViewHolderListener)
    }

    private fun createAssetViewHolder(parent: ViewGroup): FoundAccountInformationAssetViewHolder {
        return FoundAccountInformationAssetViewHolder.create(parent, assetViewHolderListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseFoundAccountInformationItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onAccountItemLongClick(accountAddress: String)
        fun onAssetItemLongClick(assetId: Long)
    }

    companion object {
        private val logTag = FoundAccountInformationAdapter::class.simpleName
    }
}
