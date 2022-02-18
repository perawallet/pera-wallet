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

package com.algorand.android.ui.accountdetail.history.datasource

import androidx.paging.PagingSource
import com.algorand.android.models.Transaction
import javax.inject.Inject

class TransactionHistoryDataSource @Inject constructor(
    private val onLoad: suspend (params: LoadParams<String>) -> LoadResult<String, Transaction>
) : PagingSource<String, Transaction>() {

    override suspend fun load(params: LoadParams<String>): LoadResult<String, Transaction> {
        return onLoad(params)
    }
}
