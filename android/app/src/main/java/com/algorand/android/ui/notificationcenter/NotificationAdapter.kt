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

package com.algorand.android.ui.notificationcenter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.NotificationItemDiffCallback
import com.algorand.android.models.NotificationListItem
import java.time.ZonedDateTime

class NotificationAdapter(
    private val onNewItemAddedToTop: () -> Unit,
    private val onNotificationItemClick: (NotificationListItem) -> Unit
) : PagingDataAdapter<NotificationListItem, NotificationItemViewHolder>(NotificationItemDiffCallback()) {

    var lastRefreshedDateTime: ZonedDateTime? = null

    private val dataObserver = object : RecyclerView.AdapterDataObserver() {
        override fun onItemRangeInserted(positionStart: Int, itemCount: Int) {
            if (positionStart == 0 && this@NotificationAdapter.itemCount > 0 && itemCount > 0) {
                onNewItemAddedToTop.invoke()
            }
        }
    }

    override fun onBindViewHolder(holder: NotificationItemViewHolder, position: Int) {
        holder.bind(getItem(position), lastRefreshedDateTime)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NotificationItemViewHolder {
        return NotificationItemViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    getItem(bindingAdapterPosition)?.let { notificationItem ->
                        onNotificationItemClick(notificationItem)
                    }
                }
            }
        }
    }

    fun registerDataObserver() {
        registerAdapterDataObserver(dataObserver)
    }

    fun unregisterDataObserver() {
        unregisterAdapterDataObserver(dataObserver)
    }
}
