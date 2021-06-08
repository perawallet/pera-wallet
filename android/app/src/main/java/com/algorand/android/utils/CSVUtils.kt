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

package com.algorand.android.utils

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.DateRange
import com.algorand.android.models.Transaction
import com.google.firebase.crashlytics.FirebaseCrashlytics
import java.io.File
import java.time.format.DateTimeFormatter
import java.util.Locale

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

fun List<Transaction>.createCSVFile(
    cacheDir: File,
    assetId: Long,
    decimal: Int,
    accountName: String,
    userAddress: String,
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
            forEachIndexed { index, transaction ->
                val amount = transaction.getAmount(includeCloseAmount = false)
                val amountFormatted = amount?.formatAmount(decimal, fullFormatNeeded = true)
                // Amount
                bufferedWriter.write("\"${amountFormatted.getSafeCSVValue()}\",")
                // Reward
                val formattedReward = (transaction.getReward(userAddress) ?: 0).formatAsAlgoString()
                bufferedWriter.write("\"${formattedReward.getSafeCSVValue()}\",")
                // Close Amount
                bufferedWriter.write("\"${transaction.closeAmount.getSafeCSVValue()}\",")
                // Close To
                bufferedWriter.write("${transaction.payment?.closeToAddress.getSafeCSVValue()},")
                // To
                bufferedWriter.write("${transaction.getReceiverAddress()},")
                // From
                bufferedWriter.write("${transaction.senderAddress.getSafeCSVValue()},")
                // Fee
                val formattedFee = (transaction.fee ?: 0).formatAsAlgoString()
                bufferedWriter.write("\"${formattedFee.getSafeCSVValue()}\",")
                // Round
                bufferedWriter.write("${transaction.confirmedRound.getSafeCSVValue()},")
                // Date
                val formattedDate =
                    transaction.roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()?.formatAsDateAndTime()
                bufferedWriter.write("\"$formattedDate\",")
                // ID
                bufferedWriter.write("${transaction.id.getSafeCSVValue()},")
                // Note
                bufferedWriter.write("\"${transaction.noteInBase64?.decodeBase64IfUTF8().getSafeCSVValue()}\"")
                if (index + 1 != count()) {
                    bufferedWriter.write("\n")
                }
            }
        }

        return tempCSVFile
    } catch (exception: Exception) {
        tempCSVFile?.delete()
        FirebaseCrashlytics.getInstance().recordException(exception)
        return null
    }
}

private fun Any?.getSafeCSVValue(): Any {
    return this ?: ""
}

private fun getCSVFileName(assetId: Long, accountName: String, dateRange: DateRange?): String {
    val csvFormatter = DateTimeFormatter.ofPattern(CSV_PATTERN)

    val fromFormatted = dateRange?.from?.format(csvFormatter)
    val toFormatted = dateRange?.to?.format(csvFormatter)
    var fileName = "${accountName}_"

    if (assetId == AssetInformation.ALGORAND_ID) {
        fileName += ALGOS_FULL_NAME.toLowerCase(Locale.ENGLISH)
    } else {
        fileName += assetId
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
