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

package com.algorand.android.modules.accountdetail.assets.ui.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountDetailQuickActionsBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.BuySellButton
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.CopyAddressButton
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.MoreButton
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.SendButton
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.ShowAddressButton
import com.algorand.android.modules.accountdetail.assets.ui.model.QuickActionItem.SwapButton
import com.google.android.material.button.MaterialButton

class AccountDetailQuickActionsViewHolder(
    private val binding: ItemAccountDetailQuickActionsBinding,
    private val listener: AccountDetailQuickActionsListener
) : BaseViewHolder<AccountDetailAssetsItem>(binding.root) {

    override fun bind(item: AccountDetailAssetsItem) {
        if (item !is AccountDetailAssetsItem.QuickActionItemContainer || areButtonsAlreadyAdded()) return
        initializeButtons(item.quickActionItemList)
    }

    private fun initializeButtons(quickActionItemList: List<QuickActionItem>) {
        val buttonIdsList = mutableListOf<Int>()
        quickActionItemList.forEach { quickActionItem ->
            val quickActionButton = createQuickActionButton()
            buttonIdsList.add(quickActionButton.id)
            binding.root.addView(quickActionButton)
            setButtonClickListener(quickActionButton, quickActionItem)
            initializeAttributes(quickActionButton, quickActionItem)
        }
        addButtonsIdToFlowContainer(buttonIdsList)
    }

    private fun createQuickActionButton(): MaterialButton {
        val quickActionButton = LayoutInflater.from(binding.root.context)
            .inflate(R.layout.layout_quick_action_item, null)
            as MaterialButton

        return quickActionButton.apply {
            id = View.generateViewId()
        }
    }

    private fun setButtonClickListener(button: MaterialButton, quickActionItem: QuickActionItem) {
        button.setOnClickListener {
            when (quickActionItem) {
                BuySellButton -> listener.onBuySellClick()
                CopyAddressButton -> listener.onCopyAddressClick()
                MoreButton -> listener.onMoreClick()
                SendButton -> listener.onSendClick()
                ShowAddressButton -> listener.onShowAddressClick()
                is SwapButton -> listener.onSwapClick()
            }
        }
    }

    private fun initializeAttributes(button: MaterialButton, quickActionItem: QuickActionItem) {
        button.apply {
            setIconResource(quickActionItem.iconResId)
            text = resources.getString(quickActionItem.labelResId)
            if (quickActionItem is SwapButton) {
                button.isSelected = quickActionItem.isSelected
            }
        }
    }

    private fun addButtonsIdToFlowContainer(idList: List<Int>) {
        binding.buttonContainerFlow.referencedIds = idList.toIntArray()
    }

    private fun areButtonsAlreadyAdded(): Boolean {
        return binding.buttonContainerFlow.referencedIds.isNotEmpty()
    }

    interface AccountDetailQuickActionsListener {
        fun onBuySellClick()
        fun onSendClick()
        fun onSwapClick()
        fun onMoreClick()
        fun onCopyAddressClick()
        fun onShowAddressClick()
    }

    companion object {
        fun create(
            parent: ViewGroup,
            listener: AccountDetailQuickActionsListener
        ): AccountDetailQuickActionsViewHolder {
            val binding = ItemAccountDetailQuickActionsBinding
                .inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountDetailQuickActionsViewHolder(binding, listener)
        }
    }
}
