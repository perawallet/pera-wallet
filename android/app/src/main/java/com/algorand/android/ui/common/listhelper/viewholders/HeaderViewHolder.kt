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

package com.algorand.android.ui.common.listhelper.viewholders

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAccountHeaderBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.utils.setDrawable

class HeaderViewHolder(val binding: ItemAccountHeaderBinding) : RecyclerView.ViewHolder(binding.root) {

    fun bind(headerAccountListItem: HeaderAccountListItem) {
        with(headerAccountListItem.accountCacheData) {
            binding.nameTextView.apply {
                setDrawable(start = AppCompatResources.getDrawable(context, getImageResource()))
                text = account.name
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): HeaderViewHolder {
            val binding = ItemAccountHeaderBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return HeaderViewHolder(binding)
        }
    }
}

data class HeaderAccountListItem(val accountCacheData: AccountCacheData) : BaseAccountListItem()
