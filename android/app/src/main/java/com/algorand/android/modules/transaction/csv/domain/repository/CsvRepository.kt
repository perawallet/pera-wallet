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

package com.algorand.android.modules.transaction.csv.domain.repository

import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import java.io.File
import java.io.InputStream

interface CsvRepository {

    suspend fun getCsv(
        cacheDirectory: File,
        publicKey: String,
        dateRange: DateRange?,
        assetId: Long?
    ): Result<InputStream>

    companion object {
        const val INJECTION_NAME = "csvRepositoryInjectionName"
        const val MAX_TXN_REQUEST_COUNT = 1000
    }
}
