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

package com.algorand.android.modules.transaction.csv.data.repository

import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.modules.transaction.csv.domain.repository.CsvRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.CSV_API_REQUEST_PATTERN
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject
import java.io.File
import java.io.InputStream
import java.time.format.DateTimeFormatter

class CsvRepositoryImpl @Inject constructor(
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val mobileAlgorandApi: MobileAlgorandApi
) : CsvRepository {

    override suspend fun getCsv(
        cacheDirectory: File,
        publicKey: String,
        dateRange: DateRange?,
        assetId: Long?
    ): Result<InputStream> {
        val csvFormatter = DateTimeFormatter.ofPattern(CSV_API_REQUEST_PATTERN)
        val fromFormatted = dateRange?.from?.format(csvFormatter)
        val toFormatted = dateRange?.to?.format(csvFormatter)
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getExportHistory(
                address = publicKey,
                startDate = fromFormatted,
                endDate = toFormatted
            )
        }.map { it.byteStream() }
    }
}
