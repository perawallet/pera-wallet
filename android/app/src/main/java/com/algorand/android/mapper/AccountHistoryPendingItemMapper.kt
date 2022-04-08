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
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.PendingTransaction
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsTxString
import java.time.ZonedDateTime
import javax.inject.Inject

class AccountHistoryPendingItemMapper @Inject constructor(
    private val transactionSymbolDecider: TransactionSymbolDecider,
    private val transactionNameDecider: TransactionNameDecider
) {

    // TODO: 30.12.2021 Mappers shouldn't contain any logic.
    fun mapTo(
        transaction: PendingTransaction,
        accountPublicKey: String,
        transactionTargetUser: TransactionTargetUser?,
        assetDetail: AssetDetail?,
        otherPublicKey: String,
        formattedAmountInDisplayedCurrency: String?
    ): BaseTransactionItem.TransactionItem.Pending {
        return with(transaction) {
            val transactionSymbol = transactionSymbolDecider.provideTransactionSymbol(this, accountPublicKey)
            val amount = getAmount()
            val nowZonedDateTime = ZonedDateTime.now()
            val decimals = assetDetail?.fractionDecimals ?: ALGO_DECIMALS
            BaseTransactionItem.TransactionItem.Pending(
                assetId = getAssetId(),
                id = null,
                signature = signatureKey,
                accountPublicKey = accountPublicKey,
                otherPublicKey = otherPublicKey,
                transactionSymbol = transactionSymbol,
                isAlgorand = isAlgorand(),
                amount = amount,
                transactionTargetUser = transactionTargetUser,
                date = nowZonedDateTime.formatAsTxString(),
                zonedDateTime = nowZonedDateTime,
                fee = detail?.fee,
                noteInB64 = detail?.noteInBase64,
                round = null,
                decimals = decimals,
                formattedFullAmount = amount.formatAmount(decimals),
                closeToAddress = null, // TODO Add CloseTo Address after model is updated.
                closeToAmount = null, // TODO Add CloseAmount after model is updated
                rewardAmount = 0L,
                assetShortName = assetDetail?.shortName,
                transactionName = transactionNameDecider.providePendingTransactionName(this, accountPublicKey),
                formattedAmountInDisplayedCurrency = formattedAmountInDisplayedCurrency
            )
        }
    }
}
