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

package com.algorand.android.ui.wcsessions

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.WalletConnectSession

class WalletConnectSessionAdapter(
    private val listener: Listener
) : ListAdapter<WalletConnectSession, WalletConnectSessionViewHolder>(WalletConnectSessionDiffUtil()) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): WalletConnectSessionViewHolder {
        return WalletConnectSessionViewHolder.create(parent, ::onDisconnectClick).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition).let { session ->
                        if (session.isConnected) return@setOnClickListener
                        listener.onSessionClick(session)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: WalletConnectSessionViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    private fun onDisconnectClick(session: WalletConnectSession) {
        listener.onDisconnectClick(session)
    }

    interface Listener {
        fun onDisconnectClick(session: WalletConnectSession)
        fun onSessionClick(session: WalletConnectSession)
    }
}
