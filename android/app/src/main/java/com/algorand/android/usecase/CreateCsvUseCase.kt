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

package com.algorand.android.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.TransactionCsvDetailMapper
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.DateRange
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionCsvDetail
import com.algorand.android.models.TransactionType
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DATE_AND_TIME_SEC_PATTERN
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.TransactionCsvFileCreator
import com.algorand.android.utils.decodeBase64IfUTF8
import com.algorand.android.utils.format
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.formatAsRFC3339Version
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import java.io.File
import java.io.IOException
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.flow

class CreateCsvUseCase @Inject constructor(
    private val totalTransactionsUseCase: TotalTransactionsUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountManager: AccountManager,
    private val transactionCsvDetailMapper: TransactionCsvDetailMapper,
    private val transactionCsvFileCreator: TransactionCsvFileCreator
) {

    fun createTransactionHistoryCsvFile(
        cacheDirectory: File,
        publicKey: String,
        dateRange: DateRange?,
        assetId: Long?,
        scope: CoroutineScope
    ) = flow<DataResource<File>> {
        emit(DataResource.Loading())
        val accountName = accountManager.getAccount(publicKey)?.name.orEmpty()
        val fromDate = dateRange?.from.formatAsRFC3339Version()
        val toDate = dateRange?.to.formatAsRFC3339Version()
        val transactionType = TransactionType.PAY_TRANSACTION.takeIf { assetId == ALGORAND_ID }?.value
        totalTransactionsUseCase.getCompleteTransactions(assetId, publicKey, fromDate, toDate, transactionType).use(
            onSuccess = { transactionList ->
                cacheNotCachedAssets(transactionList, scope)
                val transactionCsvDetailList = createTransactionCsvDetailList(publicKey, transactionList)
                val csvFile = transactionCsvFileCreator.createCSVFile(
                    transactionCsvDetailList,
                    cacheDirectory,
                    assetId,
                    accountName,
                    dateRange
                )
                if (csvFile == null) {
                    emit(DataResource.Error.Local(IOException()))
                } else {
                    emit(DataResource.Success(csvFile))
                }
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api(exception, code))
            }
        )
    }

    private fun createTransactionCsvDetailList(
        publicKey: String,
        transactionList: List<Transaction>
    ): List<TransactionCsvDetail> {
        return transactionList.map { txn ->
            val txnAssetDecimal = getTransactionAssetDecimals(txn)
            transactionCsvDetailMapper.createTransactionCsvDetail(
                transactionId = txn.id.orEmpty(),
                formattedAmount = txn.getAmount(false)?.formatAmount(txnAssetDecimal, true).orEmpty(),
                formattedReward = (txn.getReward(publicKey) ?: 0).formatAsAlgoString(),
                formattedFee = (txn.fee ?: 0).formatAsAlgoString(),
                closeAmount = txn.closeAmount.toString(),
                closeToAddress = txn.payment?.closeToAddress.orEmpty(),
                receiverAddress = txn.getReceiverAddress(),
                senderAddress = txn.senderAddress.orEmpty(),
                confirmedRound = if (txn.confirmedRound != null) txn.confirmedRound.toString() else "",
                noteAsString = txn.noteInBase64?.decodeBase64IfUTF8().orEmpty(),
                assetId = txn.assetTransfer?.assetId,
                formattedDate = txn.roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()
                    ?.format(DATE_AND_TIME_SEC_PATTERN).orEmpty()
            )
        }
    }

    private fun getTransactionAssetDecimals(transaction: Transaction): Int {
        val txnAssetId = transaction.assetTransfer?.assetId
        return when {
            txnAssetId != null -> {
                simpleAssetDetailUseCase.getCachedAssetDetail(txnAssetId)
                    ?.data?.fractionDecimals ?: DEFAULT_ASSET_DECIMAL
            }
            transaction.isAlgorand() -> ALGO_DECIMALS
            else -> DEFAULT_ASSET_DECIMAL
        }
    }

    private suspend fun cacheNotCachedAssets(transactionList: List<Transaction>, scope: CoroutineScope) {
        val assetIds = transactionList.mapNotNull { it.assetTransfer?.assetId }.toSet()
        simpleAssetDetailUseCase.cacheIfThereIsNonCachedAsset(assetIds, scope)
    }
}
