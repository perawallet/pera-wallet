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

package com.algorand.android.modules.registration.watchaccount.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.registration.watchaccount.ui.model.BasePasteableWatchAccountItem
import com.algorand.android.modules.registration.watchaccount.ui.model.BasePasteableWatchAccountItem.ItemType
import com.algorand.android.modules.registration.watchaccount.ui.model.BasePasteableWatchAccountItem.ItemType.ACCOUNT_ADDRESS_ITEM

class PasteableWatchAccountAdapter(
    private val listener: Listener
) : ListAdapter<BasePasteableWatchAccountItem, BaseViewHolder<BasePasteableWatchAccountItem>>(BaseDiffUtil()) {

    private val nfDomainItemListener = NfDomainItemViewHolder.Listener { nfDomainName, nfDomainAddress ->
        listener.onNfDomainClick(nfDomainName, nfDomainAddress)
    }

    private val accountAddressItemListener = AccountAddressItemViewHolder.Listener { accountAddress ->
        listener.onAccountAddressClick(accountAddress)
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BasePasteableWatchAccountItem> {
        return when (viewType) {
            ACCOUNT_ADDRESS_ITEM.ordinal -> createAccountAddressItemViewHolder(parent)
            ItemType.NFDOMAIN_ITEM.ordinal -> createNfDomainItemViewHolder(parent)
            else -> throw Exception("$logTag: Item View Type('$viewType') is Unknown.")
        }
    }

    private fun createNfDomainItemViewHolder(parent: ViewGroup): NfDomainItemViewHolder {
        return NfDomainItemViewHolder.create(parent, nfDomainItemListener)
    }

    private fun createAccountAddressItemViewHolder(parent: ViewGroup): AccountAddressItemViewHolder {
        return AccountAddressItemViewHolder.create(parent, accountAddressItemListener)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BasePasteableWatchAccountItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onAccountAddressClick(accountAddress: String)
        fun onNfDomainClick(nfDomainName: String, nfDomainAddress: String)
    }

    companion object {
        private val logTag = PasteableWatchAccountAdapter::class.java.simpleName
    }
}
