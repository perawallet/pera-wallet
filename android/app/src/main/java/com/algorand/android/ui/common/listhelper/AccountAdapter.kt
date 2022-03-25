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

package com.algorand.android.ui.common.listhelper

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.ui.accounts.AccountErrorItemViewHolder
import com.algorand.android.ui.accounts.AccountItemViewHolder
import com.algorand.android.ui.accounts.BasePortfolioValuesItemViewHolder.PortfolioValuesListener
import com.algorand.android.ui.accounts.HeaderViewHolder
import com.algorand.android.ui.accounts.PortfolioValuesErrorItemViewHolder
import com.algorand.android.ui.accounts.PortfolioValuesItemViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.ItemType.ACCOUNT_ERROR
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.ItemType.ACCOUNT_SUCCESS
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.ItemType.HEADER
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.ItemType.PORTFOLIO_ERROR
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.ItemType.PORTFOLIO_SUCCESS

class AccountAdapter(
    private val accountClickListener: AccountItemViewHolder.AccountClickListener,
    private val accountErrorClickListener: AccountErrorItemViewHolder.AccountClickListener,
    private val optionsClickListener: HeaderViewHolder.OptionsClickListener,
    private val portfolioValuesListener: PortfolioValuesListener
) : ListAdapter<BaseAccountListItem, BaseViewHolder<BaseAccountListItem>>(BaseDiffUtil<BaseAccountListItem>()) {

    override fun getItemViewType(position: Int): Int {
        return getItem(position).itemType.ordinal
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BaseViewHolder<BaseAccountListItem> {
        return when (viewType) {
            PORTFOLIO_SUCCESS.ordinal -> PortfolioValuesItemViewHolder.create(parent, portfolioValuesListener)
            PORTFOLIO_ERROR.ordinal -> PortfolioValuesErrorItemViewHolder.create(parent, portfolioValuesListener)
            HEADER.ordinal -> HeaderViewHolder.create(parent, optionsClickListener)
            ACCOUNT_SUCCESS.ordinal -> AccountItemViewHolder.create(parent, accountClickListener)
            ACCOUNT_ERROR.ordinal -> AccountErrorItemViewHolder.create(parent, accountErrorClickListener)
            else -> throw Exception("$logTag: Item View Type is Unknown.")
        }
    }

    override fun onBindViewHolder(holder: BaseViewHolder<BaseAccountListItem>, position: Int) {
        holder.bind(getItem(position))
    }

    companion object {
        private val logTag = AccountAdapter::class.java.simpleName
    }
}
