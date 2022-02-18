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

import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestSenderInfo
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.utils.MIN_FEE
import javax.inject.Inject

class BaseAssetTransferTransactionDetailUiBuilder @Inject constructor() :
    WalletConnectTransactionDetailBuilder<BaseAssetTransferTransaction> {

    override fun buildTransactionRequestSenderInfo(txn: BaseAssetTransferTransaction): TransactionRequestSenderInfo? {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> buildAssetOptInSenderInfo(txn)
            else -> null
        }
    }

    override fun buildTransactionRequestTransactionInfo(
        txn: BaseAssetTransferTransaction
    ): TransactionRequestTransactionInfo? {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> null
            else -> buildGeneralTransactionInfo(txn)
        }
    }

    override fun buildTransactionRequestNoteInfo(txn: BaseAssetTransferTransaction): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note)
        }
    }

    override fun buildTransactionRequestAmountInfo(txn: BaseAssetTransferTransaction): TransactionRequestAmountInfo {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> buildAssetOptInAmountInfo(txn)
            else -> buildGeneralAmountInfo(txn)
        }
    }

    override fun buildTransactionRequestExtrasInfo(txn: BaseAssetTransferTransaction): TransactionRequestExtrasInfo {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> buildAssetOptInExtrasInfo(txn)
            else -> buildGeneralExtrasInfo(txn)
        }
    }

    private fun buildAssetOptInSenderInfo(
        txn: BaseAssetTransferTransaction.AssetOptInTransaction
    ): TransactionRequestSenderInfo {
        return with(txn) {
            TransactionRequestSenderInfo(
                senderDisplayedAddress = senderAddress.decodedAddress,
                toAccountTypeImageResId = getAccountImageResource(),
                toDisplayedAddress = getProvidedAddressAsDisplayAddress(assetReceiverAddress.decodedAddress.orEmpty()),
                rekeyToAccountAddress = getRekeyToAccountAddress()?.decodedAddress,
                assetInformation = TransactionRequestAssetInformation(
                    assetId = assetId,
                    isVerified = assetParams?.isVerified,
                    fullName = assetParams?.fullName,
                    shortName = assetParams?.shortName
                )
            )
        }
    }

    private fun buildGeneralTransactionInfo(txn: BaseAssetTransferTransaction): TransactionRequestTransactionInfo {
        return with(txn) {
            TransactionRequestTransactionInfo(
                fromDisplayedAddress = getProvidedAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIcon = createAccountIcon(),
                toDisplayedAddress = assetReceiverAddress.decodedAddress,
                accountBalance = assetInformation?.amount,
                assetInformation = TransactionRequestAssetInformation(
                    assetId = assetId,
                    isVerified = assetParams?.isVerified,
                    shortName = assetParams?.shortName,
                    fullName = assetParams?.fullName,
                    decimals = assetDecimal
                ),
                rekeyToAccountAddress = getProvidedAddressAsDisplayAddress(
                    getRekeyToAccountAddress()?.decodedAddress.orEmpty()
                ),
                closeToAccountAddress = getProvidedAddressAsDisplayAddress(
                    getCloseToAccountAddress()?.decodedAddress.orEmpty()
                ),
                isLocalAccountSigner = warningCount != null
            )
        }
    }

    private fun buildGeneralAmountInfo(txn: BaseAssetTransferTransaction): TransactionRequestAmountInfo {
        return with(txn) {
            TransactionRequestAmountInfo(
                amount = transactionAmount,
                fee = fee,
                shouldShowFeeWarning = fee > MIN_FEE,
                assetDecimal = assetDecimal,
                assetShortName = assetParams?.shortName
            )
        }
    }

    private fun buildAssetOptInAmountInfo(
        txn: BaseAssetTransferTransaction.AssetOptInTransaction
    ): TransactionRequestAmountInfo {
        return with(txn) { TransactionRequestAmountInfo(fee = fee, shouldShowFeeWarning = fee > MIN_FEE) }
    }

    private fun buildAssetOptInExtrasInfo(
        txn: BaseAssetTransferTransaction.AssetOptInTransaction
    ): TransactionRequestExtrasInfo {
        return with(txn) {
            TransactionRequestExtrasInfo(
                rawTransaction = rawTransactionPayload,
                assetId = assetId,
                assetMetadata = assetParams?.appendAssetId(assetId)
            )
        }
    }

    private fun buildGeneralExtrasInfo(txn: BaseAssetTransferTransaction): TransactionRequestExtrasInfo {
        return TransactionRequestExtrasInfo(rawTransaction = txn.rawTransactionPayload)
    }
}
