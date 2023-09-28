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

package com.algorand.android.models.builder

import com.algorand.android.models.BaseKeyRegTransaction
import com.algorand.android.models.BaseKeyRegTransaction.BaseOnlineKeyRegTransaction
import com.algorand.android.models.TransactionRequestOnlineKeyRegInfo
import com.algorand.android.utils.formatNumberWithDecimalSeparators
import javax.inject.Inject

class BaseOnlineKeyRegTransactionDetailUiBuilder @Inject constructor() : BaseKeyRegTransactionDetailUiBuilder() {

    override fun buildTransactionRequestOnlineKeyRegInfo(
        txn: BaseKeyRegTransaction
    ): TransactionRequestOnlineKeyRegInfo? {
        if (txn !is BaseOnlineKeyRegTransaction) return null
        return with(txn) {
            TransactionRequestOnlineKeyRegInfo(
                voteKey = votePublicKey,
                selectionKey = selectionPublicKey,
                stateProofKey = stateProofKey,
                formattedValidFirstRound = getSafeFormattedNumber(voteFirstValidRound),
                formattedValidLastRound = getSafeFormattedNumber(voteLastValidRound),
                formattedVoteKeyDilution = getSafeFormattedNumber(voteKeyDilution)
            )
        }
    }

    private fun getSafeFormattedNumber(number: Long): String {
        return formatNumberWithDecimalSeparators(number) ?: number.toString()
    }
}
