package com.algorand.android.modules.notification.ui.viewholder

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isInvisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemNotificationBinding
import com.algorand.android.modules.notification.ui.model.NotificationListItem
import com.algorand.android.modules.notification.ui.utils.NotificationIconDrawableProvider
import com.algorand.android.utils.getRelativeTimeDifference
import java.time.ZonedDateTime

class NotificationItemViewHolder(
    private val binding: ItemNotificationBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(notificationItem: NotificationListItem?, lastRefreshedDateTime: ZonedDateTime?) {
        notificationItem?.run {
            setDescriptionText(
                message = message
            )
            setAvatar(notificationIconDrawableProvider = notificationIconDrawableProvider)
            setDate(
                time = creationDateTime,
                timeDifference = timeDifference
            )
            setReadStatus(
                creationDate = creationDateTime,
                lastRefreshedDateTime = lastRefreshedDateTime
            )
        }
    }

    private fun setAvatar(notificationIconDrawableProvider: NotificationIconDrawableProvider) {
        with(binding.avatarImageView) {
            notificationIconDrawableProvider.getNotificationIconDrawable(
                imageView = this,
                onResourceFailed = { setImageDrawable(it) }
            )
        }
    }

    private fun setDescriptionText(message: String) {
        binding.descriptionTextView.apply {
            text = message
        }
    }

    private fun setDate(time: ZonedDateTime, timeDifference: Long) {
        binding.dateTextView.apply {
            text = getRelativeTimeDifference(resources, time, timeDifference)
        }
    }

    private fun setReadStatus(creationDate: ZonedDateTime, lastRefreshedDateTime: ZonedDateTime?) {
        val isRead = if (lastRefreshedDateTime == null) {
            true // If the page is not opened before mark everything as read.
        } else {
            creationDate.isBefore(lastRefreshedDateTime)
        }
        binding.readStatusImageView.isInvisible = isRead
    }

    companion object {
        fun create(parent: ViewGroup): NotificationItemViewHolder {
            val binding = ItemNotificationBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return NotificationItemViewHolder(binding)
        }
    }
}
