/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.transactionhistory.domain.pagination

import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.PagingData
import androidx.paging.PagingSource
import androidx.paging.cachedIn
import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.repository.TransactionsRepository.Companion.DEFAULT_TRANSACTION_COUNT
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.shareIn

class TransactionHistoryPaginationHelper @Inject constructor() {

    private var transactionHistoryDataSource: TransactionHistoryDataSource? = null

    private val pagerConfig = PagingConfig(pageSize = DEFAULT_TRANSACTION_COUNT)

    var transactionPaginationFlow: SharedFlow<PagingData<BaseTransaction.Transaction>>? = null
        private set

    fun fetchTransactionHistory(
        scope: CoroutineScope,
        onLoad: suspend (nextKey: String?) -> PagingSource.LoadResult<String, BaseTransaction.Transaction>
    ) {
        if (transactionPaginationFlow == null) {
            transactionPaginationFlow = Pager(pagerConfig) {
                TransactionHistoryDataSource(onLoad).also { transactionHistoryDataSource = it }
            }.flow
                .cachedIn(scope)
                .shareIn(scope, SharingStarted.Lazily)
        } else {
            refreshTransactionHistoryData()
        }
    }

    fun refreshTransactionHistoryData() {
        transactionHistoryDataSource?.invalidate()
    }
}
