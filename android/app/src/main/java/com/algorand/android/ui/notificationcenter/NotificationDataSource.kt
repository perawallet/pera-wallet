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

import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.NotificationItem
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.modules.deeplink.DeepLinkParser
import com.algorand.android.modules.deeplink.domain.model.BaseDeepLink
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.PeraPagingSource
import com.algorand.android.utils.exceptions.MissingNotificationUserIdException
import com.algorand.android.utils.getAlgorandMobileDateFormatter
import com.algorand.android.utils.parseFormattedDate
import com.algorand.android.utils.recordException
import com.algorand.android.utils.sendErrorLog
import java.time.ZonedDateTime
import kotlinx.coroutines.coroutineScope

class NotificationDataSource(
    private val notificationRepository: NotificationRepository,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val deepLinkParser: DeepLinkParser,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val baseAssetDrawableProviderDecider: AssetDrawableProviderDecider
) : PeraPagingSource<String, NotificationListItem>() {

    override val logTag: String = NotificationDataSource::class.java.simpleName

    private var notificationUserId: String? = null

    override suspend fun initializeData(): LoadResult<String, NotificationListItem> {
        val notificationUserId = getNotificationUserId()
        return if (notificationUserId.isNullOrBlank()) {
            val exception = MissingNotificationUserIdException()
            recordException(exception)
            LoadResult.Error(exception)
        } else {
            val result = notificationRepository.getNotifications(notificationUserId)
            parseResult(result)
        }
    }

    override suspend fun loadMore(loadUrl: String): LoadResult<String, NotificationListItem> {
        val result = notificationRepository.getNotificationsMore(loadUrl)
        return parseResult(result)
    }

    private suspend fun parseResult(
        result: Result<Pagination<NotificationItem>>,
    ): LoadResult<String, NotificationListItem> {
        return when (result) {
            is Result.Success -> {
                val notificationDeepLinks = result.data.results.mapNotNull { getNotificationDeepLink(it.url) }
                cacheNonCachedNotificationAssets(notificationDeepLinks)
                val notificationListItems = result.data.results.toListItems()
                val nextKey = result.data.next
                LoadResult.Page(data = notificationListItems, prevKey = null, nextKey = nextKey)
            }
            is Result.Error -> {
                LoadResult.Error(result.exception)
            }
        }
    }

    private suspend fun getNotificationUserId(): String? {
        return notificationUserId ?: (
            deviceIdUseCase.getSelectedNodeDeviceId()?.also { newNotificationUserId ->
                notificationUserId = newNotificationUserId
            }
            )
    }

    private fun List<NotificationItem>.toListItems(): List<NotificationListItem> {
        val now = ZonedDateTime.now()
        val nowInTimeMillis = now.toInstant().toEpochMilli()
        val dateFormatter = getAlgorandMobileDateFormatter()
        return mapNotNull { notificationItem ->
            val creationZonedDateTime = notificationItem.creationDatetime.parseFormattedDate(dateFormatter) ?: now

            val timeDifference = nowInTimeMillis - creationZonedDateTime.toInstant().toEpochMilli()
            val notificationDeepLink = getNotificationDeepLink(notificationItem.url)
            notificationDeepLink?.let { deepLink ->
                // If the ID is missing or null, we shouldn't take the notification
                notificationItem.id?.let { notificationId ->
                    NotificationListItem(
                        id = notificationId,
                        type = deepLink.notificationGroupType,
                        isFailed = notificationItem.url?.isBlank() ?: true,
                        creationDateTime = creationZonedDateTime,
                        timeDifference = timeDifference,
                        message = notificationItem.message ?: "",
                        address = deepLink.address,
                        assetId = deepLink.assetId,
                        baseAssetDrawableProvider = baseAssetDrawableProviderDecider.getAssetDrawableProvider(
                            deepLink.assetId
                        )
                    )
                }
            }
        }
    }

    private fun getNotificationDeepLink(url: String?): BaseDeepLink.NotificationDeepLink? {
        if (url == null) {
            return null
        }
        val rawDeepLink = deepLinkParser.parseDeepLink(url)
        val parsedDeepLink = BaseDeepLink.create(rawDeepLink)
        return if (parsedDeepLink is BaseDeepLink.NotificationDeepLink) {
            parsedDeepLink
        } else {
            sendErrorLog("Malformed deeplink URL from notification payload")
            null
        }
    }

    private suspend fun cacheNonCachedNotificationAssets(
        notificationDeepLinks: List<BaseDeepLink.NotificationDeepLink>
    ) {
        val assetIds = notificationDeepLinks.map { it.assetId }.toSet()
        if (assetIds.isNotEmpty()) {
            coroutineScope {
                simpleAssetDetailUseCase.cacheIfThereIsNonCachedAsset(
                    assetIdList = assetIds,
                    coroutineScope = this,
                    includeDeleted = true
                )
            }
        }
    }
}
