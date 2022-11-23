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

package com.algorand.android.modules.algosdk.domain.mapper.rawtransaction

import com.algorand.android.modules.algosdk.domain.model.AlgorandAddress
import com.algorand.android.modules.algosdk.domain.model.RawTransaction
import com.algorand.android.modules.algosdk.domain.model.dto.RawTransactionDTO
import javax.inject.Inject

class RawTransactionDTOMapper @Inject constructor(
    private val applicationCallStateSchemaMapper: ApplicationCallStateSchemaMapper,
    private val assetConfigParametersMapper: AssetConfigParametersMapper,
    private val rawTransactionTypeDecider: RawTransactionTypeDTODecider
) {

    fun mapToRawTransaction(
        transactionDto: RawTransactionDTO,
        receiverAddress: AlgorandAddress?,
        senderAddress: AlgorandAddress?,
        closeToAddress: AlgorandAddress?,
        rekeyAddress: AlgorandAddress?,
        assetCloseToAddress: AlgorandAddress?,
        assetReceiverAddress: AlgorandAddress?
    ): RawTransaction {
        return RawTransaction(
            amount = transactionDto.amount,
            fee = transactionDto.fee,
            firstValidRound = transactionDto.firstValidRound,
            genesisId = transactionDto.genesisId,
            genesisHash = transactionDto.genesisHash,
            lastValidRound = transactionDto.lastValidRound,
            note = transactionDto.note,
            receiverAddress = receiverAddress,
            senderAddress = senderAddress,
            transactionType = rawTransactionTypeDecider.decideRawTransactionType(transactionDto.transactionType),
            closeToAddress = closeToAddress,
            rekeyAddress = rekeyAddress,
            assetCloseToAddress = assetCloseToAddress,
            assetReceiverAddress = assetReceiverAddress,
            assetAmount = transactionDto.assetAmount,
            assetId = transactionDto.assetId,
            appArgs = transactionDto.appArgs,
            appOnComplete = transactionDto.appOnComplete,
            appId = transactionDto.appId,
            appGlobalSchema = applicationCallStateSchemaMapper
                .mapToApplicationCallStateSchema(transactionDto.appGlobalSchema),
            appLocalSchema = applicationCallStateSchemaMapper
                .mapToApplicationCallStateSchema(transactionDto.appLocalSchema),
            appExtraPages = transactionDto.appExtraPages,
            approvalHash = transactionDto.approvalHash,
            stateHash = transactionDto.stateHash,
            assetIdBeingConfigured = transactionDto.assetIdBeingConfigured,
            assetConfigParameters = assetConfigParametersMapper
                .mapToAssetConfigParameters(transactionDto.assetConfigParameters),
            groupId = transactionDto.groupId
        )
    }
}
