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

package com.algorand.android.ui.settings.selection

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView

class SelectionAdapter<T : SelectionListItem>(
    private val onDifferentSelectionSelected: (T) -> Unit
) : RecyclerView.Adapter<SelectionItemViewHolder>() {

    private val list = mutableListOf<T>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): SelectionItemViewHolder {
        return SelectionItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val selectedListItem = list[bindingAdapterPosition]
                    if (selectedListItem.isSelected.not()) {
                        onDifferentSelectionSelected.invoke(selectedListItem)
                        deselectListItem()
                        selectedListItem.isSelected = true
                        notifyItemChanged(bindingAdapterPosition, SELECTION_CHANGED_PAYLOAD)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: SelectionItemViewHolder, position: Int) {
        holder.bind(list[position])
    }

    fun setItems(newList: List<T>) {
        list.apply {
            clear()
            addAll(newList)
        }
        notifyDataSetChanged()
    }

    private fun deselectListItem() {
        list.withIndex().find { (_, value) -> value.isSelected }?.run {
            value.isSelected = false
            notifyItemChanged(index, SELECTION_CHANGED_PAYLOAD)
        }
    }

    override fun getItemCount() = list.size

    companion object {
        private const val SELECTION_CHANGED_PAYLOAD = "selection_changed_payload"
    }
}
