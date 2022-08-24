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

package com.algorand.android.modules.transaction.detail.ui.adapter

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.ui.model.ApplicationCallAssetInformation
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import com.algorand.android.modules.transaction.detail.ui.viewholder.ApplicationCallTransactionAssetInformationViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.BaseInnerTransactionItemViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.InnerApplicationCallTransactionItemViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.InnerStandardTransactionItemViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.InnerTransactionTitleItemViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionAccountViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionAmountViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionApplicationIdViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionAssetInformationViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionChipGroupViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionCloseToAmountViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionDateViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionDividerViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionFeeViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionIdViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionInnerTransactionListItemViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionNoteViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionOnCompletionViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionSenderViewHolder
import com.algorand.android.modules.transaction.detail.ui.viewholder.TransactionStatusViewHolder
import com.algorand.android.ui.common.walletconnect.WalletConnectExtrasChipGroupView

class TransactionDetailAdapter(
    private val extrasExtrasClickListener: ExtrasClickListener? = null,
    private val longPressListener: LongPressListener? = null,
    private val tooltipListener: TooltipListener? = null,
    private val accountItemListener: AccountItemListener? = null,
    private val applicationCallTransactionListener: ApplicationCallTransactionListener? = null,
    private val innerTransactionListener: InnerTransactionListener? = null
) : ListAdapter<TransactionDetailItem, BaseViewHolder<TransactionDetailItem>>(BaseDiffUtil()) {

    private val chipGroupListener = object : WalletConnectExtrasChipGroupView.Listener {
        override fun onOpenInAlgoExplorerClick(url: String) {
            extrasExtrasClickListener?.onAlgoExplorerClick(url)
        }

        override fun onOpenInGoalSeekerClick(url: String) {
            extrasExtrasClickListener?.onGoalSeekerClick(url)
        }
    }

    private val accountViewHolderListener = object : TransactionAccountViewHolder.Listener {
        override fun onContactAdditionClick(publicKey: String) {
            accountItemListener?.onContactAdditionClick(publicKey)
        }

        override fun onAccountAddressLongClick(publicKey: String) {
            longPressListener?.onAddressLongClick(publicKey)
        }

        override fun onTooltipShowed() {
            tooltipListener?.onTooltipShowed()
        }
    }

    private val transactionIdListener = object : TransactionIdViewHolder.Listener {
        override fun onTransactionIdLongClick(transactionId: String) {
            longPressListener?.onTransactionIdLongClick(transactionId)
        }
    }

    private val innerTransactionListItemListener = TransactionInnerTransactionListItemViewHolder.Listener {
        applicationCallTransactionListener?.onInnerTransactionClick(it)
    }

    private val innerTransactionItemListener =
        object : BaseInnerTransactionItemViewHolder.InnerTransactionItemListener {
            override fun onStandardTransactionClick(
                transaction: TransactionDetailItem.InnerTransactionItem.StandardInnerTransactionItem
            ) {
                innerTransactionListener?.onStandardTransactionClick(transaction.transaction)
            }

            override fun onApplicationCallClick(
                transaction: TransactionDetailItem.InnerTransactionItem.ApplicationInnerTransactionItem
            ) {
                innerTransactionListener?.onApplicationCallClick(transaction.transaction)
            }
        }

    private val applicationCallTransactionAssetInformationListener =
        ApplicationCallTransactionAssetInformationViewHolder.ApplicationCallTransactionAssetInformationListener {
            applicationCallTransactionListener?.onShowMoreAssetClick(it)
        }

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<TransactionDetailItem> {
        return when (viewType) {
            TransactionDetailItem.ItemType.ACCOUNT_ITEM.ordinal -> createAccountViewHolder(parent)
            TransactionDetailItem.ItemType.CLOSE_TO_AMOUNT_ITEM.ordinal -> createCloseAmountViewHolder(parent)
            TransactionDetailItem.ItemType.FEE_AMOUNT_ITEM.ordinal -> createFeeAmountViewHolder(parent)
            TransactionDetailItem.ItemType.TRANSACTION_AMOUNT_ITEM.ordinal -> createTransactionAmountViewHolder(parent)
            TransactionDetailItem.ItemType.CHIP_GROUP_ITEM.ordinal -> createChipGroupViewHolder(parent)
            TransactionDetailItem.ItemType.DATE_ITEM.ordinal -> createDateViewHolder(parent)
            TransactionDetailItem.ItemType.NOTE_ITEM.ordinal -> createNoteViewHolder(parent)
            TransactionDetailItem.ItemType.TRANSACTION_ID_ITEM.ordinal -> createTransactionIdViewHolder(parent)
            TransactionDetailItem.ItemType.DIVIDER_ITEM.ordinal -> createDividerViewHolder(parent)
            TransactionDetailItem.ItemType.STATUS_ITEM.ordinal -> createStatusViewHolder(parent)
            TransactionDetailItem.ItemType.SENDER_ITEM.ordinal -> createTransactionSenderViewHolder(parent)
            TransactionDetailItem.ItemType.ON_COMPLETION_ITEM.ordinal -> createOnCompletionViewHolder(parent)
            TransactionDetailItem.ItemType.APPLICATION_CALL_ASSET_INFORMATION_ITEM.ordinal -> {
                createApplicationCallTransactionAssetInformationViewHolder(parent)
            }
            TransactionDetailItem.ItemType.ASSET_INFORMATION_ITEM.ordinal -> {
                createTransactionAssetInformationViewHolder(parent)
            }
            TransactionDetailItem.ItemType.INNER_TRANSACTION_TITLE_ITEM.ordinal -> {
                createInnerTransactionTitleItemViewHolder(parent)
            }
            TransactionDetailItem.ItemType.INNER_STANDARD_TRANSACTION_DETAIL_ITEM.ordinal -> {
                createInnerStandardTransactionItemViewHolder(parent)
            }
            TransactionDetailItem.ItemType.INNER_APPLICATION_CALL_TRANSACTION_DETAIL_ITEM.ordinal -> {
                createInnerApplicationCallTransactionItemViewHolder(parent)
            }
            TransactionDetailItem.ItemType.APPLICATION_ID_ITEM.ordinal -> {
                createTransactionApplicationIdViewHolder(parent)
            }
            TransactionDetailItem.ItemType.INNER_TRANSACTION_LIST_ITEM.ordinal -> {
                createInnerTransactionListItemViewHolder(parent)
            }
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

    private fun createTransactionAmountViewHolder(parent: ViewGroup): TransactionAmountViewHolder {
        return TransactionAmountViewHolder.create(parent)
    }

    private fun createChipGroupViewHolder(parent: ViewGroup): TransactionChipGroupViewHolder {
        return TransactionChipGroupViewHolder.create(parent, chipGroupListener)
    }

    private fun createDateViewHolder(parent: ViewGroup): TransactionDateViewHolder {
        return TransactionDateViewHolder.create(parent)
    }

    private fun createTransactionAssetInformationViewHolder(parent: ViewGroup): TransactionAssetInformationViewHolder {
        return TransactionAssetInformationViewHolder.create(parent)
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

    private fun createTransactionSenderViewHolder(parent: ViewGroup): TransactionSenderViewHolder {
        return TransactionSenderViewHolder.create(parent)
    }

    private fun createTransactionApplicationIdViewHolder(parent: ViewGroup): TransactionApplicationIdViewHolder {
        return TransactionApplicationIdViewHolder.create(parent)
    }

    private fun createOnCompletionViewHolder(parent: ViewGroup): TransactionOnCompletionViewHolder {
        return TransactionOnCompletionViewHolder.create(parent)
    }

    private fun createApplicationCallTransactionAssetInformationViewHolder(
        parent: ViewGroup
    ): ApplicationCallTransactionAssetInformationViewHolder {
        return ApplicationCallTransactionAssetInformationViewHolder.create(
            parent,
            applicationCallTransactionAssetInformationListener
        )
    }

    private fun createInnerTransactionListItemViewHolder(
        parent: ViewGroup
    ): TransactionInnerTransactionListItemViewHolder {
        return TransactionInnerTransactionListItemViewHolder.create(parent, innerTransactionListItemListener)
    }

    private fun createInnerStandardTransactionItemViewHolder(
        parent: ViewGroup
    ): InnerStandardTransactionItemViewHolder {
        return InnerStandardTransactionItemViewHolder.create(parent, innerTransactionItemListener)
    }

    private fun createInnerApplicationCallTransactionItemViewHolder(
        parent: ViewGroup
    ): InnerApplicationCallTransactionItemViewHolder {
        return InnerApplicationCallTransactionItemViewHolder.create(parent, innerTransactionItemListener)
    }

    private fun createInnerTransactionTitleItemViewHolder(parent: ViewGroup): InnerTransactionTitleItemViewHolder {
        return InnerTransactionTitleItemViewHolder.create(parent)
    }

    override fun onBindViewHolder(holder: BaseViewHolder<TransactionDetailItem>, position: Int) {
        holder.bind(getItem(position))
    }

    interface LongPressListener {
        fun onAddressLongClick(publicKey: String) {}
        fun onTransactionIdLongClick(transactionId: String)
    }

    interface ExtrasClickListener {
        fun onAlgoExplorerClick(url: String)
        fun onGoalSeekerClick(url: String)
    }

    fun interface TooltipListener {
        fun onTooltipShowed()
    }

    fun interface AccountItemListener {
        fun onContactAdditionClick(address: String)
    }

    interface ApplicationCallTransactionListener {
        fun onInnerTransactionClick(transactions: List<BaseTransactionDetail>)
        fun onShowMoreAssetClick(assetInformationList: List<ApplicationCallAssetInformation>)
    }

    interface InnerTransactionListener {
        fun onStandardTransactionClick(transaction: BaseTransactionDetail)
        fun onApplicationCallClick(transaction: BaseTransactionDetail.ApplicationCallTransaction)
    }

    companion object {
        private val logTag = TransactionDetailAdapter::class.simpleName
    }
}
