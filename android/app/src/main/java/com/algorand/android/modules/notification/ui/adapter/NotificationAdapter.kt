package com.algorand.android.modules.notification.ui.adapter

import android.view.ViewGroup
import androidx.paging.PagingDataAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.modules.notification.ui.model.NotificationListItem
import com.algorand.android.modules.notification.ui.viewholder.NotificationItemViewHolder
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
