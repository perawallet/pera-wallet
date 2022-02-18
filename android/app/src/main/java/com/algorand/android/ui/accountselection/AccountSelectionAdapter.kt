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

package com.algorand.android.ui.accountselection

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.ui.accounts.AccountItemViewHolder
import com.algorand.android.ui.common.listhelper.BaseAccountListItem

class AccountSelectionAdapter(
    private val accountClickListener: AccountItemViewHolder.AccountClickListener,
) : ListAdapter<BaseAccountListItem, AccountItemViewHolder>(BaseDiffUtil<BaseAccountListItem>()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): AccountItemViewHolder {
        return AccountItemViewHolder.create(parent, accountClickListener)
    }

    override fun onBindViewHolder(holder: AccountItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
}
