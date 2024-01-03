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

package com.algorand.android.modules.transaction.common.data.mapper

import com.algorand.android.modules.transaction.common.data.model.TransactionResponse
import com.algorand.android.modules.transaction.common.domain.model.TransactionDTO
import javax.inject.Inject

class TransactionDTOMapper @Inject constructor(
    private val assetTransferMapper: AssetTransferDTOMapper,
    private val assetConfigurationMapper: AssetConfigurationDTOMapper,
    private val applicationCallMapper: ApplicationCallDTOMapper,
    private val paymentMapper: PaymentDTOMapper,
    private val assetFreezeMapper: AssetFreezeDTOMapper,
    private val transactionTypeMapper: TransactionTypeDTOMapper,
    private val signatureDTOMapper: SignatureDTOMapper,
    private val keyRegTransactionDTOMapper: KeyRegTransactionDTOMapper
) {

    fun mapToTransactionDTO(transactionResponse: TransactionResponse): TransactionDTO {
        with(transactionResponse) {
            return TransactionDTO(
                assetTransfer = assetTransfer?.let { assetTransferMapper.mapToAssetTransferDTO(it) },
                assetConfiguration = assetConfiguration?.let {
                    assetConfigurationMapper.mapToAssetConfigurationDTO(it)
                },
                applicationCall = applicationCall?.let { applicationCallMapper.mapToApplicationCallDTO(it) },
                closeAmount = closeAmount,
                confirmedRound = confirmedRound,
                signature = signature?.let { signatureDTOMapper.mapToSignatureDTO(it) },
                fee = fee,
                id = id,
                senderAddress = senderAddress,
                payment = payment?.let { paymentMapper.mapToPaymentDTO(it) },
                assetFreezeTransaction = assetFreezeTransaction?.let { assetFreezeMapper.mapToAssetFreezeDTO(it) },
                noteInBase64 = noteInBase64,
                roundTimeAsTimestamp = roundTimeAsTimestamp,
                rekeyTo = rekeyTo,
                transactionType = transactionType?.let { transactionTypeMapper.mapToTransactionTypeDTO(it) },
                innerTransactions = innerTransactions?.map { mapToTransactionDTO(it) },
                createdAssetIndex = createdAssetIndex,
                keyRegTransactionDTO = keyRegTransaction?.let {
                    keyRegTransactionDTOMapper.mapToKeyRegTransactionDTO(it)
                }
            )
        }
    }
}
