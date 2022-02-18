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

package com.algorand.android.ui.accountdetail.history.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAccountHistoryTitleBinding
import com.algorand.android.models.BaseTransactionItem

class AccountHistoryTitleViewHolder(
    private val binding: ItemAccountHistoryTitleBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(headerItemString: BaseTransactionItem.StringTitleItem) {
        binding.titleTextView.text = headerItemString.title
    }

    fun bind(headerTitleRes: BaseTransactionItem.ResourceTitleItem) {
        binding.titleTextView.setText(headerTitleRes.stringRes)
    }

    companion object {
        fun create(parent: ViewGroup): AccountHistoryTitleViewHolder {
            val binding = ItemAccountHistoryTitleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return AccountHistoryTitleViewHolder(binding)
        }
    }
}
