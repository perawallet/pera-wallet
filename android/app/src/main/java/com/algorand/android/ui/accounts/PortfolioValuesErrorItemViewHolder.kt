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

package com.algorand.android.ui.accounts

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.ItemPortfolioValuesBinding
import com.algorand.android.models.BaseViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.utils.extensions.setDrawableTintColor

class PortfolioValuesErrorItemViewHolder(
    override val binding: ItemPortfolioValuesBinding,
    private val portfolioValuesListener: PortfolioValuesListener
) : BasePortfolioValuesItemViewHolder(binding) {

    override fun bindPortfolioItem(item: BaseAccountListItem.BasePortfolioValueItem) {
        if (item !is BaseAccountListItem.BasePortfolioValueItem.PortfolioValuesErrorItem) return
        with(binding) {
            val notAvailableText = root.resources.getString(R.string.not_available_shortened)
            algoHoldingsTextView.text = notAvailableText
            assetHoldingsTextView.text = notAvailableText
            portfolioValueTextView.text = notAvailableText
            portfolioValueTitleTextView.apply {
                setTextColor(ContextCompat.getColor(root.context, item.titleColorResId))
                setDrawableTintColor(item.titleColorResId)
                setOnClickListener { portfolioValuesListener.onPortfolioInfoClick(item) }
            }
        }
    }

    companion object {
        fun create(
            parent: ViewGroup,
            portfolioValuesListener: PortfolioValuesListener
        ): BaseViewHolder<BaseAccountListItem> {
            val binding = ItemPortfolioValuesBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return PortfolioValuesErrorItemViewHolder(binding, portfolioValuesListener)
        }
    }
}
