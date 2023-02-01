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

package com.algorand.android.customviews.alertview.ui.usecase

import android.content.Context
import com.algorand.android.models.NotificationMetadata
import com.algorand.android.models.NotificationType
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.setupAlgoReceivedMessage
import com.algorand.android.utils.setupAlgoSentMessage
import com.algorand.android.utils.setupAssetSupportSuccessMessage
import com.algorand.android.utils.setupFailedMessage
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

class GetTitleForAlertNotificationUseCase @Inject constructor(
    @ApplicationContext private val context: Context,
    private val getAccountNameIfPossibleUseCase: GetAccountNameIfPossibleUseCase
) {

    suspend operator fun invoke(notificationMetadata: NotificationMetadata): String {
        with(notificationMetadata) {
            val senderName = getAccountNameIfPossibleUseCase.invoke(senderPublicKey)
            val receiverName = getAccountNameIfPossibleUseCase.invoke(receiverPublicKey)

            return when (getNotificationType()) {
                NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    // TODO: return annotated string instead of char sequence and apply annotated style in UI layer
                    context.setupAlgoReceivedMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    // TODO: return annotated string instead of char sequence and apply annotated style in UI layer
                    context.setupAlgoSentMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.TRANSACTION_FAILED, NotificationType.ASSET_TRANSACTION_FAILED -> {
                    val assetDescription = getAssetDescription()
                    val formattedAmount = safeAmount.formatAmount(
                        assetDescription.decimals ?: ALGO_DECIMALS
                    )
                    // TODO: return annotated string instead of char sequence and apply annotated style in UI layer
                    context.setupFailedMessage(
                        formattedAmount,
                        senderName,
                        receiverName,
                        assetDescription
                    )
                }
                NotificationType.ASSET_SUPPORT_SUCCESS -> {
                    // TODO: return annotated string instead of char sequence and apply annotated style in UI layer
                    context.setupAssetSupportSuccessMessage(senderPublicKey, getAssetDescription())
                }
                NotificationType.UNKNOWN, NotificationType.BROADCAST -> alertMessage
                else -> null
            }.toString()
        }
    }
}
