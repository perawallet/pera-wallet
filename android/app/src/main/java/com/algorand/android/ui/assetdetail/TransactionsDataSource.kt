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

package com.algorand.android.ui.assetdetail

import androidx.lifecycle.MutableLiveData
import androidx.paging.PagingSource
import com.algorand.android.models.Account
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.models.User
import com.algorand.android.repository.AccountRepository
import com.algorand.android.utils.formatAsRFC3339Version
import com.algorand.android.utils.toListItems
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.withContext

class TransactionsDataSource(
    private val pendingLiveData: MutableLiveData<List<BaseTransactionListItem>>,
    private val accountRepository: AccountRepository,
    private val publicKey: String,
    private val assetId: Long,
    private val decimals: Int,
    private val accountList: List<Account>,
    private val contactList: List<User>,
    private val isRewardsIncluded: Boolean,
    private var dateRange: DateRange? = null
) : PagingSource<String, BaseTransactionListItem>() {

    override suspend fun load(params: LoadParams<String>): LoadResult<String, BaseTransactionListItem> {
        return withContext(Dispatchers.IO) {
            try {
                val response = accountRepository.getTransactions(
                    assetId = assetId,
                    publicKey = publicKey,
                    fromDate = dateRange?.from.formatAsRFC3339Version(),
                    toDate = dateRange?.to.formatAsRFC3339Version(),
                    nextToken = params.key
                )
                when (response) {
                    is Result.Success -> {
                        val newList = response.data.transactionList.toListItems(
                            assetId, decimals, publicKey, accountList, contactList, isRewardsIncluded
                        )
                        async {
                            removePendingTransactions(newList)
                        }
                        LoadResult.Page(
                            data = newList,
                            prevKey = null,
                            nextKey = response.data.nextToken
                        )
                    }
                    is Result.Error -> {
                        LoadResult.Error<String, BaseTransactionListItem>(response.exception)
                    }
                }
            } catch (exception: Exception) {
                LoadResult.Error<String, BaseTransactionListItem>(exception)
                // Handle errors in this block and return LoadResult.Error if it is an
                // expected error (such as a network failure).
            }
        }
    }

    private fun removePendingTransactions(newList: List<BaseTransactionListItem>) {
        val currentPendingList = pendingLiveData.value?.toMutableList() ?: mutableListOf()
        var isListChanged = false
        currentPendingList.removeAll { pendingItem ->
            val isPendingTransactionConfirmed = newList.any { newListItem -> pendingItem.isSame(newListItem) }
            if (isPendingTransactionConfirmed) {
                isListChanged = true
            }
            return@removeAll isPendingTransactionConfirmed
        }
        if (isListChanged) {
            pendingLiveData.postValue(currentPendingList)
        }
    }
}
