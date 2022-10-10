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

import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.TransactionRequestAmountInfo
import com.algorand.android.models.TransactionRequestAssetInformation
import com.algorand.android.models.TransactionRequestExtrasInfo
import com.algorand.android.models.TransactionRequestNoteInfo
import com.algorand.android.models.TransactionRequestTransactionInfo
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.decodeBase64IfUTF8
import javax.inject.Inject

class BaseAssetConfigurationTransactionDetailUiBuilder @Inject constructor(
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider
) :
    WalletConnectTransactionDetailBuilder<BaseAssetConfigurationTransaction> {

    override fun buildTransactionRequestNoteInfo(txn: BaseAssetConfigurationTransaction): TransactionRequestNoteInfo? {
        return when (txn) {
            is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> buildAssetCreationNoteInfo(txn)
            else -> buildGeneralNoteInfo(txn)
        }
    }

    override fun buildTransactionRequestExtrasInfo(
        txn: BaseAssetConfigurationTransaction
    ): TransactionRequestExtrasInfo {
        return when (txn) {
            is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> buildAssetCreationExtrasInfo(txn)
            is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                buildAssetReconfigurationExtrasInfo(txn)
            }
            is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> buildAssetDeletionExtrasInfo(txn)
        }
    }

    override fun buildTransactionRequestAmountInfo(
        txn: BaseAssetConfigurationTransaction
    ): TransactionRequestAmountInfo {
        return when (txn) {
            is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> buildAssetCreationAmountInfo(txn)
            is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                buildAssetReconfigurationAmountInfo(txn)
            }
            is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> buildAssetDeletionAmountInfo(txn)
        }
    }

    override fun buildTransactionRequestTransactionInfo(
        txn: BaseAssetConfigurationTransaction
    ): TransactionRequestTransactionInfo {
        return when (txn) {
            is BaseAssetConfigurationTransaction.BaseAssetCreationTransaction -> buildAssetCreationTransactionInfo(txn)
            is BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction -> {
                buildAssetReconfigurationTransactionInfo(txn)
            }
            is BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction -> buildAssetDeletionTransactionInfo(txn)
        }
    }

    private fun buildAssetReconfigurationTransactionInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction
    ): TransactionRequestTransactionInfo {
        return with(txn) {
            TransactionRequestTransactionInfo(
                fromDisplayedAddress = getFromAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIcon = createAccountIconResource(),
                reconfigurationAsset = TransactionRequestAssetInformation(
                    assetId = assetId,
                    fullName = assetName,
                    shortName = shortName,
                    verificationTierConfiguration =
                    verificationTierConfigurationDecider.decideVerificationTierConfiguration(verificationTier)
                ),
                rekeyToAccountAddress = getFromAddressAsDisplayAddress(
                    getRekeyToAccountAddress()?.decodedAddress.orEmpty()
                ),
                closeToAccountAddress = getFromAddressAsDisplayAddress(
                    getCloseToAccountAddress()?.decodedAddress.orEmpty()
                )
            )
        }
    }

    private fun buildAssetCreationTransactionInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
    ): TransactionRequestTransactionInfo {
        return with(txn) {
            TransactionRequestTransactionInfo(
                fromDisplayedAddress = getFromAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIcon = createAccountIconResource(),
                assetName = assetName,
                assetUnitName = unitName,
                isAssetUnnamed = assetName == null,
                rekeyToAccountAddress = getFromAddressAsDisplayAddress(
                    getRekeyToAccountAddress()?.decodedAddress.orEmpty()
                ),
                closeToAccountAddress = getFromAddressAsDisplayAddress(
                    getCloseToAccountAddress()?.decodedAddress.orEmpty()
                )
            )
        }
    }

    private fun buildAssetDeletionTransactionInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction
    ): TransactionRequestTransactionInfo {
        return with(txn) {
            TransactionRequestTransactionInfo(
                fromDisplayedAddress = getFromAddressAsDisplayAddress(senderAddress.decodedAddress.orEmpty()),
                fromAccountIcon = createAccountIconResource(),
                assetInformation = TransactionRequestAssetInformation(
                    assetId = assetId,
                    fullName = assetName,
                    shortName = shortName,
                    verificationTierConfiguration =
                    verificationTierConfigurationDecider.decideVerificationTierConfiguration(verificationTier)
                ),
                showDeletionWarning = true,
                rekeyToAccountAddress = getFromAddressAsDisplayAddress(
                    getRekeyToAccountAddress()?.decodedAddress.orEmpty()
                ),
                closeToAccountAddress = getFromAddressAsDisplayAddress(
                    getCloseToAccountAddress()?.decodedAddress.orEmpty()
                )
            )
        }
    }

    private fun buildAssetReconfigurationAmountInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction
    ): TransactionRequestAmountInfo {
        return with(txn) {
            TransactionRequestAmountInfo(
                fee = fee,
                shouldShowFeeWarning = fee > MIN_FEE,
                managerAccount = getFromAddressAsDisplayAddress(managerAddress?.decodedAddress.orEmpty()),
                reserveAccount = getFromAddressAsDisplayAddress(reserveAddress?.decodedAddress.orEmpty()),
                freezeAccount = getFromAddressAsDisplayAddress(frozenAddress?.decodedAddress.orEmpty()),
                clawbackAccount = getFromAddressAsDisplayAddress(clawbackAddress?.decodedAddress.orEmpty())
            )
        }
    }

    private fun buildAssetCreationAmountInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
    ): TransactionRequestAmountInfo {
        return with(txn) {
            TransactionRequestAmountInfo(
                amount = transactionAmount,
                fee = fee,
                shouldShowFeeWarning = fee > MIN_FEE,
                decimalPlaces = decimals,
                assetDecimal = assetDecimal,
                defaultFrozen = isFrozen,
                managerAccount = getFromAddressAsDisplayAddress(managerAddress?.decodedAddress.orEmpty()),
                reserveAccount = getFromAddressAsDisplayAddress(reserveAddress?.decodedAddress.orEmpty()),
                freezeAccount = getFromAddressAsDisplayAddress(frozenAddress?.decodedAddress.orEmpty()),
                clawbackAccount = getFromAddressAsDisplayAddress(clawbackAddress?.decodedAddress.orEmpty())
            )
        }
    }

    private fun buildAssetDeletionAmountInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction
    ): TransactionRequestAmountInfo {
        return with(txn) { TransactionRequestAmountInfo(fee = fee, shouldShowFeeWarning = fee > MIN_FEE) }
    }

    private fun buildAssetCreationNoteInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
    ): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank() && metadataHash?.decodeBase64IfUTF8().isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note, assetMetadata = metadataHash?.decodeBase64IfUTF8())
        }
    }

    private fun buildGeneralNoteInfo(txn: BaseAssetConfigurationTransaction): TransactionRequestNoteInfo? {
        with(txn) {
            if (note.isNullOrBlank()) return null
            return TransactionRequestNoteInfo(note = note)
        }
    }

    private fun buildAssetDeletionExtrasInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction
    ): TransactionRequestExtrasInfo {
        return with(txn) {
            TransactionRequestExtrasInfo(
                rawTransaction = rawTransactionPayload,
                assetUrl = url,
                assetMetadata = walletConnectTransactionAssetDetail
            )
        }
    }

    private fun buildAssetReconfigurationExtrasInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction
    ): TransactionRequestExtrasInfo {
        return with(txn) {
            TransactionRequestExtrasInfo(
                rawTransaction = rawTransactionPayload,
                assetUrl = url,
                assetId = assetId
            )
        }
    }

    private fun buildAssetCreationExtrasInfo(
        txn: BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
    ): TransactionRequestExtrasInfo {
        return with(txn) { TransactionRequestExtrasInfo(rawTransaction = rawTransactionPayload, assetUrl = url) }
    }
}
