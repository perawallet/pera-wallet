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

package com.algorand.android.modules.transaction.csv.ui.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.DateRange
import com.algorand.android.modules.transaction.csv.domain.usecase.CreateCsvUseCase
import com.algorand.android.modules.transaction.csv.ui.mapper.CsvStatusPreviewMapper
import com.algorand.android.modules.transaction.csv.ui.model.CsvStatusPreview
import java.io.File
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class CsvStatusPreviewUseCase @Inject constructor(
    private val createCsvUseCase: CreateCsvUseCase,
    private val csvStatusPreviewMapper: CsvStatusPreviewMapper
) : BaseUseCase() {

    fun createCsvFile(
        cacheDir: File,
        dateRange: DateRange?,
        publicKey: String,
        scope: CoroutineScope,
        assetId: Long? = null
    ): Flow<CsvStatusPreview> {
        return createCsvUseCase.createTransactionHistoryCsvFile(
            cacheDirectory = cacheDir,
            publicKey = publicKey,
            dateRange = dateRange,
            assetId = assetId,
            scope = scope
        ).map { csvStatusPreviewMapper.mapToCsvStatus(it) }
    }
}
