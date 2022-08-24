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

package com.algorand.android.models.builder

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.utils.ALGO_FULL_NAME
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.MIN_FEE
import javax.inject.Inject

class BasePaymentTransactionDetailUiBuilder @Inject constructor() :
    WalletConnectTransactionDetailBuilder<BasePaymentTransaction> {

    override fun buildTransactionRequestTransactionInfo(
        txn: BasePaymentTransaction
    ): TransactionRequestTransactionInfo {
        return with(txn) {
            TransactionRequestTransactionInfo(
                fromDisplayedAddress = getProvidedAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIcon = createAccountIconResource(),
                toDisplayedAddress = receiverAddress.decodedAddress,
                accountBalance = assetInformation?.amount,
                assetInformation = TransactionRequestAssetInformation(
                    assetId = ALGO_ID,
                    isVerified = true,
                    shortName = ALGO_SHORT_NAME,
                    fullName = ALGO_FULL_NAME,
                    decimals = assetDecimal
                ),
                rekeyToAccountAddress = getProvidedAddressAsDisplayAddress(
                    getRekeyToAccountAddress()?.decodedAddress.orEmpty()
                ),
                closeToAccountAddress = getProvidedAddressAsDisplayAddress(
                    getCloseToAccountAddress()?.decodedAddress.orEmpty()
                )
            )
        }
    }

    override fun buildTransactionRequestAmountInfo(txn: BasePaymentTransaction): TransactionRequestAmountInfo {
        return with(txn) {
            TransactionRequestAmountInfo(
                amount = transactionAmount,
                fee = fee,
                shouldShowFeeWarning = fee > MIN_FEE,
                assetDecimal = assetDecimal,
                assetShortName = ALGO_SHORT_NAME
            )
        }
    }

    override fun buildTransactionRequestNoteInfo(txn: BasePaymentTransaction): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note)
        }
    }

    override fun buildTransactionRequestExtrasInfo(txn: BasePaymentTransaction): TransactionRequestExtrasInfo {
        return TransactionRequestExtrasInfo(rawTransaction = txn.rawTransactionPayload)
    }
}
