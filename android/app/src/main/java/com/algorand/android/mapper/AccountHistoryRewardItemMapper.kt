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

import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.formatAsTxString
import java.math.BigDecimal
import javax.inject.Inject

class AccountHistoryRewardItemMapper @Inject constructor() {

    // TODO: 30.12.2021 Mappers shouldn't contain any logic.
    fun mapTo(
        transaction: BaseTransactionItem.TransactionItem?,
        assetQueryItem: AssetQueryItem?,
        accountPublicKey: String,
        transactionTargetUser: TransactionTargetUser?,
        selectedCurrencySymbol: String,
        amountInSelectedCurrency: BigDecimal?
    ): BaseTransactionItem.TransactionItem.Reward? {
        return transaction?.run {
            val reward = rewardAmount
            if (reward != null && reward != 0L) {
                val decimal = assetQueryItem?.fractionDecimals ?: ALGO_DECIMALS
                val formattedSelectedCurrencyValue = amountInSelectedCurrency?.formatAsCurrency(selectedCurrencySymbol)
                BaseTransactionItem.TransactionItem.Reward(
                    amountInMicroAlgos = reward,
                    id = id,
                    date = zonedDateTime?.formatAsTxString().orEmpty(),
                    signature = signature,
                    accountPublicKey = accountPublicKey,
                    otherPublicKey = otherPublicKey,
                    isAlgorand = isAlgorand,
                    transactionTargetUser = transactionTargetUser,
                    zonedDateTime = zonedDateTime,
                    amount = amount,
                    fee = fee,
                    noteInB64 = noteInB64,
                    decimals = decimal,
                    formattedFullAmount = amount.formatAmount(decimal),
                    rewardAmount = reward,
                    assetId = assetQueryItem?.assetId,
                    amountInSelectedCurrency = amountInSelectedCurrency,
                    formattedSelectedCurrencyValue = formattedSelectedCurrencyValue
                )
            } else {
                null
            }
        }
    }
}
