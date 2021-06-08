/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.models

import androidx.recyclerview.widget.DiffUtil

class TransactionDiffCallback : DiffUtil.ItemCallback<BaseTransactionListItem>() {
    override fun areItemsTheSame(oldItem: BaseTransactionListItem, newItem: BaseTransactionListItem): Boolean {
        return oldItem.isSame(newItem)
    }

    override fun areContentsTheSame(oldItem: BaseTransactionListItem, newItem: BaseTransactionListItem): Boolean {
        if (oldItem is TransactionListItem && newItem is TransactionListItem) {
            return oldItem == newItem
        }
        if (oldItem is ClaimedRewardListItem && newItem is ClaimedRewardListItem) {
            return oldItem == newItem
        }
        return false
    }
}
