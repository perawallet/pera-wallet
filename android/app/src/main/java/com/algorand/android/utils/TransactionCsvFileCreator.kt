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

package com.algorand.android.utils

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.DateRange
import com.algorand.android.models.TransactionCsvDetail
import java.io.File
import java.time.format.DateTimeFormatter
import java.util.Locale
import javax.inject.Inject

class TransactionCsvFileCreator @Inject constructor() {

    private val csvKeys =
        listOf(
            "Amount",
            "Reward",
            "Close Amount",
            "Close To: Address",
            "To: Address",
            "From: Address",
            "Fee",
            "Round",
            "Date",
            "ID",
            "Note"
        )

    fun createCSVFile(
        transactionCsvDetailList: List<TransactionCsvDetail>,
        cacheDir: File,
        assetId: Long?,
        accountName: String,
        dateRange: DateRange?
    ): File? {
        var tempCSVFile: File? = null
        try {
            val csvDirectory = File(cacheDir, "csvfiles")
            csvDirectory.mkdirs()
            tempCSVFile = File(csvDirectory, getCSVFileName(assetId, accountName, dateRange))

            tempCSVFile.bufferedWriter().use { bufferedWriter ->
                bufferedWriter.write(csvKeys.joinToString(","))
                bufferedWriter.write("\n")
                transactionCsvDetailList.forEachIndexed { index, transaction ->
                    // Amount
                    bufferedWriter.write("\"${transaction.formattedAmount}\",")
                    // Reward
                    bufferedWriter.write("\"${transaction.formattedReward}\",")
                    // Close Amount
                    bufferedWriter.write("\"${transaction.closeAmount}\",")
                    // Close To
                    bufferedWriter.write("${transaction.closeToAddress},")
                    // To
                    bufferedWriter.write("${transaction.receiverAddress},")
                    // From
                    bufferedWriter.write("${transaction.senderAddress},")
                    // Fee
                    bufferedWriter.write("\"${transaction.formattedFee}\",")
                    // Round
                    bufferedWriter.write("${transaction.confirmedRound},")
                    // Date
                    bufferedWriter.write("\"${transaction.formattedDate}\",")
                    // ID
                    bufferedWriter.write("${transaction.transactionId},")
                    // Note
                    bufferedWriter.write("\"${transaction.noteAsString}\"")
                    if (index + 1 != transactionCsvDetailList.count()) {
                        bufferedWriter.write("\n")
                    }
                }
            }

            return tempCSVFile
        } catch (exception: Exception) {
            tempCSVFile?.delete()
            recordException(exception)
            return null
        }
    }

    private fun Any?.getSafeCSVValue(): Any {
        return this ?: ""
    }

    private fun getCSVFileName(assetId: Long?, accountName: String, dateRange: DateRange?): String {
        val csvFormatter = DateTimeFormatter.ofPattern(CSV_PATTERN)

        val fromFormatted = dateRange?.from?.format(csvFormatter)
        val toFormatted = dateRange?.to?.format(csvFormatter)
        var fileName = "${accountName}_"

        if (assetId == AssetInformation.ALGORAND_ID) {
            fileName += ALGOS_FULL_NAME.lowercase(Locale.ENGLISH)
        } else {
            fileName += assetId.getSafeCSVValue()
        }

        if (fromFormatted != null) {
            fileName += "-$fromFormatted"
        }
        if (toFormatted != null && toFormatted != fromFormatted) {
            fileName += if (fromFormatted != null) "_" else "-"
            fileName += toFormatted
        }
        return "$fileName.csv"
    }
}
