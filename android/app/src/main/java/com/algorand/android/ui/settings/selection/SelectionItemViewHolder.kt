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

package com.algorand.android.ui.settings.selection

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemSelectionBinding
import com.algorand.android.utils.setDrawable

class SelectionItemViewHolder(
    private val binding: ItemSelectionBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(selectionListItem: SelectionListItem) {
        binding.root.text = selectionListItem.getVisibleName(itemView.context)
        bindSelection(selectionListItem)
    }

    fun bindSelection(selectionListItem: SelectionListItem) {
        binding.root.setDrawable(
            end = if (selectionListItem.isSelected) {
                AppCompatResources.getDrawable(itemView.context, R.drawable.ic_check_20dp)
            } else {
                null
            }
        )
    }

    companion object {
        fun create(parent: ViewGroup): SelectionItemViewHolder {
            val binding = ItemSelectionBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return SelectionItemViewHolder(binding)
        }
    }
}
