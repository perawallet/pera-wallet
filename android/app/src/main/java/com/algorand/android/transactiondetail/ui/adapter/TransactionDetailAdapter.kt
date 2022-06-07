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

package com.algorand.android.transactiondetail.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.transactiondetail.domain.model.TransactionDetailItem
import com.algorand.android.transactiondetail.ui.viewholder.TransactionAccountViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionAmountViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionChipGroupViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionCloseToAmountViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionDateViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionDividerViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionFeeViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionIdViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionNoteViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionRewardViewHolder
import com.algorand.android.transactiondetail.ui.viewholder.TransactionStatusViewHolder
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasChipGroupView

class TransactionDetailAdapter(
    private val clickListener: ClickListener,
    private val longClickListener: LongClickListener,
    private val tooltipListener: TooltipListener
) : ListAdapter<TransactionDetailItem, BaseViewHolder<TransactionDetailItem>>(BaseDiffUtil()) {

    private val chipGroupListener = object : WalletConnectExtrasChipGroupView.Listener {
        override fun onOpenInAlgoExplorerClick(url: String) {
            clickListener.onAlgoExplorerClick(url)
        }

        override fun onOpenInGoalSeekerClick(url: String) {
            clickListener.onGoalSeekerClick(url)
        }
    }

    private val accountViewHolderListener = object : TransactionAccountViewHolder.Listener {
        override fun onContactAdditionClick(publicKey: String) {
            clickListener.onContactAdditionClick(publicKey)
        }

        override fun onAccountAddressLongClick(publicKey: String) {
            longClickListener.onAddressLongClick(publicKey)
        }

        override fun onTooltipShowed() {
            tooltipListener.onTooltipShowed()
        }
    }

    private val transactionIdListener = object : TransactionIdViewHolder.Listener {
        override fun onTransactionIdLongClick(transactionId: String) {
            longClickListener.onTransactionIdLongClick(transactionId)
        }
    }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<TransactionDetailItem> {
        return when (viewType) {
            TransactionDetailItem.ItemType.ACCOUNT_ITEM.ordinal -> createAccountViewHolder(parent)
            TransactionDetailItem.ItemType.CLOSE_TO_AMOUNT_ITEM.ordinal -> createCloseAmountViewHolder(parent)
            TransactionDetailItem.ItemType.FEE_AMOUNT_ITEM.ordinal -> createFeeAmountViewHolder(parent)
            TransactionDetailItem.ItemType.REWARD_AMOUNT_ITEM.ordinal -> createRewardAmountViewHolder(parent)
            TransactionDetailItem.ItemType.TRANSACTION_AMOUNT_ITEM.ordinal -> createTransactionAmountViewHolder(parent)
            TransactionDetailItem.ItemType.CHIP_GROUP_ITEM.ordinal -> createChipGroupViewHolder(parent)
            TransactionDetailItem.ItemType.DATE_ITEM.ordinal -> createDateViewHolder(parent)
            TransactionDetailItem.ItemType.NOTE_ITEM.ordinal -> createNoteViewHolder(parent)
            TransactionDetailItem.ItemType.TRANSACTION_ID_ITEM.ordinal -> createTransactionIdViewHolder(parent)
            TransactionDetailItem.ItemType.DIVIDER_ITEM.ordinal -> createDividerViewHolder(parent)
            TransactionDetailItem.ItemType.STATUS_ITEM.ordinal -> createStatusViewHolder(parent)
            else -> throw Exception("$logTag list item is unknown")
        }
    }

    private fun createAccountViewHolder(parent: ViewGroup): TransactionAccountViewHolder {
        return TransactionAccountViewHolder.create(parent, accountViewHolderListener)
    }

    private fun createCloseAmountViewHolder(parent: ViewGroup): TransactionCloseToAmountViewHolder {
        return TransactionCloseToAmountViewHolder.create(parent)
    }

    private fun createFeeAmountViewHolder(parent: ViewGroup): TransactionFeeViewHolder {
        return TransactionFeeViewHolder.create(parent)
    }

    private fun createRewardAmountViewHolder(parent: ViewGroup): TransactionRewardViewHolder {
        return TransactionRewardViewHolder.create(parent)
    }

    private fun createTransactionAmountViewHolder(parent: ViewGroup): TransactionAmountViewHolder {
        return TransactionAmountViewHolder.create(parent)
    }

    private fun createChipGroupViewHolder(parent: ViewGroup): TransactionChipGroupViewHolder {
        return TransactionChipGroupViewHolder.create(parent, chipGroupListener)
    }

    private fun createDateViewHolder(parent: ViewGroup): TransactionDateViewHolder {
        return TransactionDateViewHolder.create(parent)
    }

    private fun createNoteViewHolder(parent: ViewGroup): TransactionNoteViewHolder {
        return TransactionNoteViewHolder.create(parent)
    }

    private fun createTransactionIdViewHolder(parent: ViewGroup): TransactionIdViewHolder {
        return TransactionIdViewHolder.create(parent, transactionIdListener)
    }

    private fun createDividerViewHolder(parent: ViewGroup): TransactionDividerViewHolder {
        return TransactionDividerViewHolder.create(parent)
    }

    private fun createStatusViewHolder(parent: ViewGroup): TransactionStatusViewHolder {
        return TransactionStatusViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<TransactionDetailItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface LongClickListener {
        fun onAddressLongClick(publicKey: String)
        fun onTransactionIdLongClick(transactionId: String)
    }

    interface ClickListener {
        fun onAlgoExplorerClick(url: String)
        fun onGoalSeekerClick(url: String)
        fun onContactAdditionClick(publicKey: String)
    }

    interface TooltipListener {
        fun onTooltipShowed()
    }

    companion object {
        private const val logTag = "TransactionDetailAdapter"
    }
}
