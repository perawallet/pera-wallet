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

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.mapper.NotificationCenterPreviewMapper
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.NotificationCenterPreview
import com.algorand.android.models.NotificationGroupType
import com.algorand.android.models.NotificationListItem
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
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
    private val notificationRepository: NotificationRepository,
    private val isThereAnyAccountWithPublicKeyUseCase: IsThereAnyAccountWithPublicKeyUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
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
        if (!checkIfAccountStillExists(publicKey)) {
            emit(getNotificationPreviewWithErrorMessage(ACCOUNT_DOESN_T_EXIST_ERROR_RES_ID))
            return@flow
        }
        when (getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, publicKey)) {
            is BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onGoingCollectibleDetailEvent = Event(publicKey to assetId)
                    )
                )
            }
            is BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData -> {
                emit(notificationCenterPreviewMapper.mapTo(onGoingAssetDetailEvent = Event(publicKey to assetId)))
            }
            null -> emit(notificationCenterPreviewMapper.mapTo(onHistoryNotAvailableEvent = Event(publicKey)))
        }
    }

    fun checkRequestedAssetType(assetId: Long, accountAddress: String) = flow {
        if (!checkIfAccountStillExists(accountAddress)) {
            emit(getNotificationPreviewWithErrorMessage(ACCOUNT_DOESN_T_EXIST_ERROR_RES_ID))
            return@flow
        }
        if (!accountDetailUseCase.canAccountSignTransaction(accountAddress)) {
            emit(getNotificationPreviewWithErrorMessage(R.string.you_cannot_optin))
            return@flow
        }
        val isAsset = simpleAssetDetailUseCase.isAssetCached(assetId)
        val isCollectible = simpleCollectibleUseCase.isCollectibleCached(assetId)
        when {
            isCollectible -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onGoingCollectibleProfileEvent = Event(accountAddress to assetId)
                    )
                )
            }
            isAsset -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onGoingAssetProfileEvent = Event(accountAddress to assetId)
                    )
                )
            }
        }
    }

    fun onNotificationClickEvent(notificationListItem: NotificationListItem) = flow {
        if (notificationListItem.isFailed) return@flow
        if (!checkIfAccountStillExists(notificationListItem.address)) {
            emit(getNotificationPreviewWithErrorMessage(ACCOUNT_DOESN_T_EXIST_ERROR_RES_ID))
            return@flow
        }
        when (notificationListItem.type) {
            NotificationGroupType.TRANSACTIONS -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onTransactionEvent = Event(
                            Pair(
                                notificationListItem.address,
                                notificationListItem.assetId
                            )
                        )
                    )
                )
            }
            NotificationGroupType.OPTIN -> {
                emit(
                    notificationCenterPreviewMapper.mapTo(
                        onAssetSupportRequestEvent = Event(
                            Pair(
                                notificationListItem.address,
                                notificationListItem.assetId
                            )
                        )
                    )
                )
            }
        }
    }

    private fun checkIfAccountStillExists(accountAddress: String): Boolean {
        return isThereAnyAccountWithPublicKeyUseCase.isThereAnyAccountWithPublicKey(accountAddress)
    }

    private fun getNotificationPreviewWithErrorMessage(@StringRes errorStringRes: Int): NotificationCenterPreview {
        return notificationCenterPreviewMapper.mapTo(
            errorMessageResId = Event(errorStringRes)
        )
    }

    companion object {
        private const val ACCOUNT_DOESN_T_EXIST_ERROR_RES_ID = R.string.you_cannot_take
    }
}
