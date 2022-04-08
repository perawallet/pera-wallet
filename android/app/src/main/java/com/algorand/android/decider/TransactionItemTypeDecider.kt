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

package com.algorand.android.decider

import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionItemType
import com.algorand.android.utils.isEqualTo
import java.math.BigInteger
import javax.inject.Inject

class TransactionItemTypeDecider @Inject constructor() {

    fun provideTransactionItemType(transaction: Transaction): TransactionItemType {
        return when {
            isAssetCreationTransaction(transaction) -> TransactionItemType.ASSET_CREATION
            isInPending(transaction) -> TransactionItemType.PENDING
            isAssetRemovalTransaction(transaction) -> TransactionItemType.ASSET_REMOVAL
            isRekeyTransaction(transaction) -> TransactionItemType.REKEY
            else -> TransactionItemType.TRANSFER
        }
    }

    private fun isInPending(transaction: Transaction): Boolean {
        return with(transaction) { confirmedRound == null || confirmedRound == 0L }
    }

    private fun isAssetCreationTransaction(transaction: Transaction): Boolean {
        return with(transaction) {
            assetTransfer != null && senderAddress == assetTransfer.receiverAddress &&
                assetTransfer.amount isEqualTo BigInteger.ZERO
        }
    }

    private fun isAssetRemovalTransaction(transaction: Transaction): Boolean {
        return with(transaction) {
            assetTransfer != null &&
                assetTransfer.amount isEqualTo BigInteger.ZERO &&
                senderAddress != assetTransfer.receiverAddress &&
                assetTransfer.closeTo != null
        }
    }

    private fun isRekeyTransaction(transaction: Transaction): Boolean {
        return with(transaction) {
            payment != null &&
                payment.amount isEqualTo BigInteger.ZERO &&
                rekeyTo != null
        }
    }
}
