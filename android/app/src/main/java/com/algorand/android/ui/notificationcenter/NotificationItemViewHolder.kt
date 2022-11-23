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

package com.algorand.android.ui.notificationcenter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isInvisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemNotificationBinding
import com.algorand.android.models.NotificationListItem
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
            setAvatar(
                isFailed = isFailed
            )
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

    private fun setAvatar(
        isFailed: Boolean
    ) {
        with(binding.avatarImageView) {
            if (isFailed) {
                setImageResource(R.drawable.ic_default_failed_notification)
            } else {
                setImageResource(R.drawable.ic_algo_green_round)
            }
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
