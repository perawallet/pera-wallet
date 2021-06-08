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

import android.content.SharedPreferences
import androidx.paging.PagingSource
import com.algorand.android.core.AccountManager
import com.algorand.android.database.ContactDao
import com.algorand.android.models.Account
import com.algorand.android.models.NotificationItem
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.NotificationType
import com.algorand.android.models.Result
import com.algorand.android.models.User
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.getAlgorandMobileDateFormatter
import com.algorand.android.utils.getUserIfSavedLocally
import com.algorand.android.utils.parseFormattedDate
import com.algorand.android.utils.preference.getNotificationUserId
import java.time.ZonedDateTime
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class NotificationDataSource(
    private val notificationRepository: NotificationRepository,
    private val sharedPref: SharedPreferences,
    private val contactDao: ContactDao,
    accountManager: AccountManager
) : PagingSource<String, NotificationListItem>() {

    private val accountList = accountManager.getAccounts()

    private var cachedContactList: List<User>? = null

    private var notificationUserId: String? = null

    override suspend fun load(params: LoadParams<String>): LoadResult<String, NotificationListItem> {
        return withContext(Dispatchers.IO) {
            try {
                val currentKey = params.key
                val response = if (currentKey == null) {
                    notificationRepository.getNotifications(getNotificationUserId())
                } else {
                    notificationRepository.getNotificationsMore(currentKey)
                }
                return@withContext when (response) {
                    is Result.Success -> {
                        val list = response.data.results.toListItems(getCachedContacts(), accountList)
                        val nextKey = response.data.next
                        LoadResult.Page(list, currentKey, nextKey)
                    }
                    is Result.Error -> {
                        LoadResult.Error<String, NotificationListItem>(response.exception)
                    }
                }
            } catch (exception: Exception) {
                LoadResult.Error<String, NotificationListItem>(exception)
                // Handle errors in this block and return LoadResult.Error if it is an
                // expected error (such as a network failure).
            }
        }
    }

    private fun getNotificationUserId(): String {
        return notificationUserId ?: (sharedPref.getNotificationUserId()?.also { newNotificationUserId ->
            notificationUserId = newNotificationUserId
        } ?: throw Exception("Notification User ID couldn't found"))
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
            val formattedAmount = notificationItem.metadata?.amount.formatAmount(decimals)

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
