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

import com.algorand.android.core.AccountManager
import com.algorand.android.database.ContactDao
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.Account
import com.algorand.android.models.NotificationItem
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.NotificationType
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.models.User
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.PeraPagingSource
import com.algorand.android.utils.exceptions.MissingNotificationUserIdException
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getAlgorandMobileDateFormatter
import com.algorand.android.utils.getUserIfSavedLocally
import com.algorand.android.utils.parseFormattedDate
import com.algorand.android.utils.recordException
import java.time.ZonedDateTime
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class NotificationDataSource(
    private val notificationRepository: NotificationRepository,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val contactDao: ContactDao,
    accountManager: AccountManager
) : PeraPagingSource<String, NotificationListItem>() {

    override val logTag: String = NotificationDataSource::class.java.simpleName

    private val accountList = accountManager.getAccounts()

    private var cachedContactList: List<User>? = null

    private var notificationUserId: String? = null

    override suspend fun initializeData(): LoadResult<String, NotificationListItem> {
        val notificationUserId = getNotificationUserId()
        return if (notificationUserId.isNullOrBlank()) {
            val exception = MissingNotificationUserIdException()
            recordException(exception)
            LoadResult.Error<String, NotificationListItem>(exception)
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
                val list = result.data.results.toListItems(getCachedContacts(), accountList)
                val nextKey = result.data.next
                LoadResult.Page(data = list, prevKey = null, nextKey = nextKey)
            }
            is Result.Error -> {
                LoadResult.Error<String, NotificationListItem>(result.exception)
            }
        }
    }

    private suspend fun getNotificationUserId(): String? {
        return notificationUserId ?: (deviceIdUseCase.getSelectedNodeDeviceId()?.also { newNotificationUserId ->
            notificationUserId = newNotificationUserId
        })
    }

    private suspend fun getCachedContacts(): List<User> {
        return withContext(Dispatchers.IO) {
            cachedContactList ?: contactDao.getAll().also { contactsInDatabase ->
                cachedContactList = contactsInDatabase
            }
        }
    }

    private fun List<NotificationItem>.toListItems(
        contactList: List<User>,
        accountList: List<Account>
    ): List<NotificationListItem> {
        val now = ZonedDateTime.now()
        val nowInTimeMillis = now.toInstant().toEpochMilli()
        val dateFormatter = getAlgorandMobileDateFormatter()
        return map { notificationItem ->
            val creationZonedDateTime = notificationItem.creationDate.parseFormattedDate(dateFormatter) ?: now

            val senderUser = getUserIfSavedLocally(
                contactList,
                accountList,
                notificationItem.metadata?.senderPublicKey
            )
            val receiverUser = getUserIfSavedLocally(
                contactList,
                accountList,
                notificationItem.metadata?.receiverPublicKey
            )

            val decimals = notificationItem.metadata?.getAssetDescription()?.decimals ?: ALGO_DECIMALS
            val formattedAmount = notificationItem.metadata?.safeAmount.formatAmount(decimals)

            val timeDifference = nowInTimeMillis - creationZonedDateTime.toInstant().toEpochMilli()

            NotificationListItem(
                id = notificationItem.id,
                type = notificationItem.type ?: NotificationType.UNKNOWN,
                creationDateTime = creationZonedDateTime,
                timeDifference = timeDifference,
                formattedAmount = formattedAmount,
                fallbackMessage = notificationItem.message.orEmpty(),
                senderUser = senderUser,
                receiverUser = receiverUser,
                metadata = notificationItem.metadata
            )
        }
    }
}
