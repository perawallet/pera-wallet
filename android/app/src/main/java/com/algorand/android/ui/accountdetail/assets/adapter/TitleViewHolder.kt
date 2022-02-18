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

package com.algorand.android.ui.accountdetail.assets.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemAccountTitleBinding
import com.algorand.android.models.AccountDetailAssetsItem

class TitleViewHolder(private val binding: ItemAccountTitleBinding) : RecyclerView.ViewHolder(binding.root) {

    fun bind(titleItem: AccountDetailAssetsItem.TitleItem) {
        binding.titleTextView.setText(titleItem.titleRes)
    }

    companion object {
        fun create(parent: ViewGroup): TitleViewHolder {
            val binding = ItemAccountTitleBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return TitleViewHolder(binding)
        }
    }
}
