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

package com.algorand.android.usecase

import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.mapper.NotificationCenterPreviewMapper
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.NotificationType
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.Event
import com.algorand.android.utils.orNow
import com.algorand.android.utils.parseFormattedDate
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class NotificationCenterUseCase @Inject constructor(
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val notificationCenterPreviewMapper: NotificationCenterPreviewMapper,
    private val assetActionMapper: AssetActionMapper,
    private val notificationRepository: NotificationRepository
) {

    fun setLastRefreshedDateTime(zonedDateTime: ZonedDateTime) {
        val lastRefreshedZonedDateTimeAsString = zonedDateTime.format(DateTimeFormatter.ISO_DATE_TIME)
        notificationRepository.saveLastRefreshedDateTime(lastRefreshedZonedDateTimeAsString)
    }

    fun getLastRefreshedDateTime(): ZonedDateTime {
        val lastRefreshedZonedDateTimeAsString = notificationRepository.getLastRefreshedDateTime()
        return lastRefreshedZonedDateTimeAsString.parseFormattedDate(DateTimeFormatter.ISO_DATE_TIME).orNow()
    }

    fun checkClickedNotificationItemType(assetId: Long, publicKey: String) = flow {
        when (getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, publicKey)) {
            is BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onGoingCollectibleDetailEvent = Event(Pair(publicKey, assetId))
                    )
                )
            }
            is BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData -> {
                emit(notificationCenterPreviewMapper.mapTo(onGoingAssetDetailEvent = Event(Pair(publicKey, assetId))))
            }
            null -> emit(notificationCenterPreviewMapper.mapTo(onHistoryNotAvailableEvent = Event(publicKey)))
        }
    }

    fun onNotificationClickEvent(notificationListItem: NotificationListItem) = flow {
        val notificationMetadata = notificationListItem.metadata ?: return@flow
        val assetInformation = notificationMetadata.getAssetDescription().convertToAssetInformation()
        val assetId = assetInformation.assetId
        when (notificationListItem.type) {
            NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                val publicKey = notificationMetadata.receiverPublicKey.orEmpty()
                emit(
                    notificationCenterPreviewMapper.mapTo(onTransactionReceivedEvent = Event(Pair(publicKey, assetId)))
                )
            }
            NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                val publicKey = notificationMetadata.senderPublicKey.orEmpty()
                emit(notificationCenterPreviewMapper.mapTo(onTransactionSentEvent = Event(Pair(publicKey, assetId))))
            }
            NotificationType.ASSET_SUPPORT_REQUEST -> {
                val publicKey = notificationMetadata.receiverPublicKey.orEmpty()
                val assetAction = assetActionMapper.mapTo(
                    assetId = assetId,
                    publicKey = publicKey,
                    asset = assetInformation
                )
                emit(notificationCenterPreviewMapper.mapTo(onAssetSupportRequestEvent = Event(assetAction)))
            }
        }
    }
}
