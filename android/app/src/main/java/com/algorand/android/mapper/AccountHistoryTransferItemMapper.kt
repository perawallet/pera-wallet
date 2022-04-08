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

package com.algorand.android.mapper

import com.algorand.android.decider.TransactionNameDecider
import com.algorand.android.decider.TransactionSymbolDecider
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionItemType
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import javax.inject.Inject

class AccountHistoryTransferItemMapper @Inject constructor(
    private val transactionSymbolDecider: TransactionSymbolDecider,
    private val transactionNameDecider: TransactionNameDecider
) {
    // TODO: 30.12.2021 Mappers shouldn't contain any logic.
    fun mapTo(
        transaction: Transaction,
        assetDetail: BaseAssetDetail?,
        accountPublicKey: String,
        transactionTargetUser: TransactionTargetUser?,
        otherPublicKey: String,
        formattedAmountInDisplayedCurrency: String?
    ): BaseTransactionItem.TransactionItem {
        return with(transaction) {
            val transactionSymbol = transactionSymbolDecider.provideTransactionSymbol(this, accountPublicKey)
            val zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()
            val decimal = assetDetail?.fractionDecimals ?: ALGO_DECIMALS
            BaseTransactionItem.TransactionItem.Transaction(
                assetId = assetDetail?.assetId,
                id = id,
                signature = signature?.signatureKey,
                accountPublicKey = accountPublicKey,
                otherPublicKey = otherPublicKey,
                transactionSymbol = transactionSymbol,
                transactionItemType = TransactionItemType.TRANSFER,
                isAlgorand = isAlgorand(),
                transactionTargetUser = transactionTargetUser,
                zonedDateTime = zonedDateTime,
                date = zonedDateTime?.formatAsTxString().orEmpty(),
                amount = getAmount(includeCloseAmount = false),
                fee = fee,
                noteInB64 = noteInBase64,
                round = confirmedRound,
                decimals = decimal,
                formattedFullAmount = getAmount(includeCloseAmount = true).formatAmount(decimal),
                closeToAddress = getCloseToAddress(),
                closeToAmount = closeAmount,
                rewardAmount = getReward(accountPublicKey),
                assetShortName = assetDetail?.shortName.orEmpty(),
                transactionName = transactionNameDecider.provideTransferTransactionName(this, accountPublicKey),
                formattedAmountInDisplayedCurrency = formattedAmountInDisplayedCurrency
            )
        }
    }
}
