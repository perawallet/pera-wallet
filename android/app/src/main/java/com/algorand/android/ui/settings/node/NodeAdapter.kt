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

package com.algorand.android.ui.settings.node

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.Node
import com.algorand.android.utils.extensions.clearAndAddAll

class NodeAdapter(
    private val onDifferentNodeSelected: (Node) -> Unit
) : RecyclerView.Adapter<NodeViewHolder>() {

    private val currentList = mutableListOf<Node>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NodeViewHolder {
        return createNodeViewHolder(parent)
    }

    private fun createNodeViewHolder(parent: ViewGroup): NodeViewHolder {
        return NodeViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val activatedNode = currentList[bindingAdapterPosition]
                    if (!activatedNode.isActive) {
                        onDifferentNodeSelected(activatedNode)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: NodeViewHolder, position: Int) {
        holder.bind(currentList[position])
    }

    override fun getItemCount(): Int = currentList.size

    fun setNewList(list: List<Node>) {
        currentList.clearAndAddAll(list)
        notifyDataSetChanged()
    }
}
