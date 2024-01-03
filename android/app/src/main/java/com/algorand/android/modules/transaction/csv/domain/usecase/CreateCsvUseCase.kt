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

package com.algorand.android.modules.transaction.csv.domain.usecase

import com.algorand.android.models.DateRange
import com.algorand.android.modules.transaction.csv.domain.repository.CsvRepository
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.recordException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import javax.inject.Inject
import javax.inject.Named

class CreateCsvUseCase @Inject constructor(
    @Named(CsvRepository.INJECTION_NAME)
    private val csvRepository: CsvRepository
) {

    fun createTransactionHistoryCsvFile(
        cacheDirectory: File,
        publicKey: String,
        dateRange: DateRange?,
        assetId: Long?
    ) = flow<DataResource<File>> {
        emit(DataResource.Loading())
        csvRepository.getCsv(
            cacheDirectory,
            publicKey,
            dateRange,
            assetId
        ).use(
            onSuccess = { inputStream ->
                val csvDirectory = File(cacheDirectory, CSV_FILES_FOLDER)
                val tempCSVFile = File(csvDirectory, "$publicKey.csv")
                var csvFile: File? = null
                try {
                    csvDirectory.mkdirs()
                    try {
                        withContext(Dispatchers.IO) {
                            val outputStream = FileOutputStream(tempCSVFile)
                            outputStream.use { output ->
                                val buffer = ByteArray(BYTEARRAY_SIZE)
                                var readData: Int
                                readData = inputStream.read(buffer)
                                while (readData != -1) {
                                    output.write(buffer, 0, readData)
                                    readData = inputStream.read(buffer)
                                }
                                output.flush()
                            }
                            csvFile = tempCSVFile
                        }
                    } catch (exception: Exception) {
                        recordException(exception)
                    } finally {
                        withContext(Dispatchers.IO) {
                            inputStream.close()
                        }
                    }
                } catch (exception: Exception) {
                    tempCSVFile.delete()
                    recordException(exception)
                }
                csvFile?.let {
                    emit(DataResource.Success(it))
                } ?: emit(DataResource.Error.Local(IOException()))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api(exception, code))
            }
        )
    }
    companion object {
        private const val BYTEARRAY_SIZE = 4 * 1024
        private const val CSV_FILES_FOLDER = "csvFiles"
    }
}
