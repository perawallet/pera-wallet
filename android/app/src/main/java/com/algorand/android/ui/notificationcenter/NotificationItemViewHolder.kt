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

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.net.toUri
import androidx.core.view.isInvisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemNotificationBinding
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.models.User
import com.algorand.android.utils.getRelativeTimeDifference
import com.algorand.android.utils.loadContactProfileImage
import com.algorand.android.utils.loadImage
import com.algorand.android.utils.setupAlgoReceivedMessage
import com.algorand.android.utils.setupAlgoSentMessage
import com.algorand.android.utils.setupAssetSupportRequestMessage
import com.algorand.android.utils.setupAssetSupportSuccessMessage
import com.algorand.android.utils.setupFailedMessage
import com.algorand.android.utils.toShortenedAddress
import java.time.ZonedDateTime

class NotificationItemViewHolder(
    private val binding: ItemNotificationBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(notificationItem: NotificationListItem?, lastRefreshedDateTime: ZonedDateTime?) {
        notificationItem?.run {
            setDescriptionText(type, formattedAmount, metadata, senderUser, receiverUser, fallbackMessage)
            setAvatar(type, senderUser, receiverUser)
            setDate(creationDateTime, timeDifference)
            setReadStatus(creationDateTime, lastRefreshedDateTime)
        }
    }

    private fun setAvatar(
        type: NotificationType,
        senderUser: User?,
        receiverUser: User?
    ) {
        if (type == NotificationType.ASSET_TRANSACTION_FAILED || type == NotificationType.ASSET_TRANSACTION_FAILED) {
            binding.avatarImageView.loadImage(R.drawable.ic_default_failed_notification)
            return
        }

        val avatarUser = when (type) {
            NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED,
            NotificationType.ASSET_SUPPORT_REQUEST, NotificationType.ASSET_SUPPORT_SUCCESS -> {
                senderUser
            }
            NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                receiverUser
            }
            else -> null
        }
        if (avatarUser != null) {
            binding.avatarImageView.loadContactProfileImage(avatarUser.imageUriAsString?.toUri())
        } else {
            binding.avatarImageView.loadImage(R.drawable.ic_default_successful_notification)
        }
    }

    private fun setDescriptionText(
        type: NotificationType,
        formattedAmount: String?,
        metadata: NotificationMetadata?,
        senderUser: User?,
        receiverUser: User?,
        fallbackMessage: String
    ) {
        val senderName = senderUser?.name ?: metadata?.senderPublicKey.toShortenedAddress()
        val receiverName = receiverUser?.name ?: metadata?.receiverPublicKey.toShortenedAddress()
        val assetDescription = metadata?.getAssetDescription()
        binding.descriptionTextView.apply {
            text = when (type) {
                NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                    context?.setupAlgoReceivedMessage(
                        formattedAmount = formattedAmount,
                        senderName = senderName,
                        receiverName = receiverName,
                        asset = assetDescription
                    )
                }
                NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                    context?.setupAlgoSentMessage(
                        formattedAmount = formattedAmount,
                        senderName = senderName,
                        receiverName = receiverName,
                        asset = assetDescription
                    )
                }
                NotificationType.TRANSACTION_FAILED, NotificationType.ASSET_TRANSACTION_FAILED -> {
                    context?.setupFailedMessage(
                        formattedAmount = formattedAmount,
                        senderName = senderName,
                        receiverName = receiverName,
                        asset = assetDescription
                    )
                }
                NotificationType.ASSET_SUPPORT_SUCCESS -> {
                    context?.setupAssetSupportSuccessMessage(
                        senderName = senderName,
                        asset = assetDescription
                    )
                }
                NotificationType.ASSET_SUPPORT_REQUEST -> {
                    context?.setupAssetSupportRequestMessage(
                        senderName = senderName,
                        asset = assetDescription
                    )
                }
                NotificationType.UNKNOWN, NotificationType.BROADCAST -> fallbackMessage
            }
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
