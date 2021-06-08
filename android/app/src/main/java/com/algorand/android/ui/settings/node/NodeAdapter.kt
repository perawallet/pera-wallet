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

package com.algorand.android.ui.settings.node

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.Node

class NodeAdapter(
    private val onNodeActivated: (Node, List<Node>) -> Unit
) : RecyclerView.Adapter<NodeViewHolder>() {

    private var nodeList = mutableListOf<Node>()
    private var activeNode: Node? = null

    fun setNodeList(nodeList: List<Node>) {
        this.nodeList.clear()
        this.nodeList.addAll(nodeList)
        activeNode = this.nodeList.find { it.isActive }
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NodeViewHolder {
        return NodeViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    if (binding.radioButton.isChecked.not()) {
                        nodeList.forEach { it.isActive = false }
                        val activatedNode = nodeList[bindingAdapterPosition].apply { isActive = true }
                        activeNode = activatedNode
                        onNodeActivated(activatedNode, nodeList)
                        notifyDataSetChanged()
                    }
                }
            }
        }
    }

    override fun getItemCount() = nodeList.size

    override fun onBindViewHolder(holder: NodeViewHolder, position: Int) {
        holder.bind(nodeList[position], activeNode)
    }
}
