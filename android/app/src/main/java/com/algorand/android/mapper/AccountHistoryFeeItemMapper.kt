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

import com.algorand.android.decider.TransactionItemTypeDecider
import com.algorand.android.decider.TransactionNameDecider
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import javax.inject.Inject

class AccountHistoryFeeItemMapper @Inject constructor(
    private val transactionItemTypeDecider: TransactionItemTypeDecider,
    private val transactionNameDecider: TransactionNameDecider
) {

    fun mapTo(
        transaction: Transaction,
        assetDetail: BaseAssetDetail?,
        accountPublicKey: String,
        transactionTargetUser: TransactionTargetUser?
    ): BaseTransactionItem.TransactionItem.Fee {
        return with(transaction) {
            val zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()
            val decimal = assetDetail?.fractionDecimals ?: ALGO_DECIMALS
            val transactionItemType = transactionItemTypeDecider.provideTransactionItemType(this)
            BaseTransactionItem.TransactionItem.Fee(
                // Since all fee transaction items is using Algo, we can set assetId as ALGORAND_ID manually
                assetId = ALGORAND_ID,
                id = id,
                signature = signature?.signatureKey,
                accountPublicKey = accountPublicKey,
                isAlgorand = isAlgorand(),
                zonedDateTime = zonedDateTime,
                transactionTargetUser = transactionTargetUser,
                date = zonedDateTime?.formatAsTxString().orEmpty(),
                fee = fee,
                noteInB64 = noteInBase64,
                round = confirmedRound,
                formattedFullAmount = getAmount(includeCloseAmount = true).formatAmount(decimal),
                closeToAddress = getCloseToAddress(),
                closeToAmount = closeAmount,
                rewardAmount = getReward(accountPublicKey),
                assetShortName = assetDetail?.shortName,
                decimals = decimal,
                transactionItemType = transactionItemType,
                transactionName = transactionNameDecider.provideTransactionName(transactionItemType),
                otherPublicKey = assetTransfer?.receiverAddress
            )
        }
    }
}
