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

package com.algorand.android.modules.transaction.detail.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import com.algorand.android.databinding.ItemTransactionAccountBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem

class TransactionAccountViewHolder(
    private val binding: ItemTransactionAccountBinding,
    private val listener: Listener
) : BaseViewHolder<TransactionDetailItem>(binding.root) {

    override fun bind(item: TransactionDetailItem) {
        if (item !is TransactionDetailItem.StandardTransactionItem.AccountItem) return
        with(binding) {
            accountLabelTextView.setText(item.labelTextRes)
            root.setOnLongClickListener { listener.onAccountAddressLongClick(item.publicKey); true }
            accountView.setOnAddButtonClickListener { listener.onContactAdditionClick(it) }
        }
        when (item) {
            is TransactionDetailItem.StandardTransactionItem.AccountItem.ContactItem -> bindContact(item)
            is TransactionDetailItem.StandardTransactionItem.AccountItem.NormalItem -> bindAccount(item)
            is TransactionDetailItem.StandardTransactionItem.AccountItem.WalletItem -> bindWallet(item)
        }
        if (item.showToolTipView) listener.onTooltipShowed()
    }

    private fun bindWallet(walletItem: TransactionDetailItem.StandardTransactionItem.AccountItem.WalletItem) {
        with(walletItem) {
            binding.accountView.setAccount(
                name = displayAddress,
                accountIconDrawablePreview = accountIconDrawablePreview,
                publicKey = publicKey,
                enableAddressCopy = false,
                showTooltip = walletItem.showToolTipView
            )
        }
    }

    private fun bindContact(contactItem: TransactionDetailItem.StandardTransactionItem.AccountItem.ContactItem) {
        with(contactItem) {
            binding.accountView.setContact(
                name = displayAddress,
                imageUriAsString = contactUri,
                publicKey = publicKey,
                enableAddressCopy = false,
                showTooltip = contactItem.showToolTipView
            )
        }
    }

    private fun bindAccount(normalItem: TransactionDetailItem.StandardTransactionItem.AccountItem.NormalItem) {
        with(normalItem) {
            binding.accountView.setAddress(
                displayAddress = displayAddress,
                publicKey = publicKey,
                showAddButton = normalItem.isAccountAdditionButtonVisible,
                enableAddressCopy = false,
                showTooltip = normalItem.showToolTipView
            )
        }
    }

    interface Listener {
        fun onTooltipShowed()
        fun onContactAdditionClick(publicKey: String)
        fun onAccountAddressLongClick(publicKey: String)
    }

    companion object {
        fun create(parent: ViewGroup, listener: Listener): TransactionAccountViewHolder {
            val binding = ItemTransactionAccountBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TransactionAccountViewHolder(binding, listener)
        }
    }
}
