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

package com.algorand.android.modules.algosdk.data.mapper.rawtransaction

import com.algorand.android.modules.algosdk.data.model.rawtransaction.RawTransactionPayload
import com.algorand.android.modules.algosdk.domain.model.dto.RawTransactionDTO
import javax.inject.Inject

class RawTransactionDTOMapper @Inject constructor(
    private val applicationCallStateSchemaDTOMapper: ApplicationCallStateSchemaDTOMapper,
    private val assetConfigParametersDTOMapper: AssetConfigParametersDTOMapper,
    private val rawTransactionTypeDTODecider: RawTransactionTypeDTODecider
) {

    fun mapToRawTransactionDTO(rawTransactionPayload: RawTransactionPayload): RawTransactionDTO {
        return RawTransactionDTO(
            amount = rawTransactionPayload.amount,
            fee = rawTransactionPayload.fee,
            firstValidRound = rawTransactionPayload.firstValidRound,
            genesisId = rawTransactionPayload.genesisId,
            genesisHash = rawTransactionPayload.genesisHash,
            lastValidRound = rawTransactionPayload.lastValidRound,
            note = rawTransactionPayload.note,
            receiverAddress = rawTransactionPayload.receiverAddress,
            senderAddress = rawTransactionPayload.senderAddress,
            transactionType = rawTransactionTypeDTODecider
                .decideRawTransactionTypeDTO(rawTransactionPayload.transactionType),
            closeToAddress = rawTransactionPayload.closeToAddress,
            rekeyAddress = rawTransactionPayload.rekeyAddress,
            assetCloseToAddress = rawTransactionPayload.assetCloseToAddress,
            assetReceiverAddress = rawTransactionPayload.assetReceiverAddress,
            assetAmount = rawTransactionPayload.assetAmount,
            assetId = rawTransactionPayload.assetId,
            appArgs = rawTransactionPayload.appArgs,
            appOnComplete = rawTransactionPayload.appOnComplete,
            appId = rawTransactionPayload.appId,
            appGlobalSchema = applicationCallStateSchemaDTOMapper
                .mapToApplicationCallStateSchemaDTO(rawTransactionPayload.appGlobalSchema),
            appLocalSchema = applicationCallStateSchemaDTOMapper
                .mapToApplicationCallStateSchemaDTO(rawTransactionPayload.appLocalSchema),
            appExtraPages = rawTransactionPayload.appExtraPages,
            approvalHash = rawTransactionPayload.approvalHash,
            stateHash = rawTransactionPayload.stateHash,
            assetIdBeingConfigured = rawTransactionPayload.assetIdBeingConfigured,
            assetConfigParameters = assetConfigParametersDTOMapper
                .mapToAssetConfigParametersDTO(rawTransactionPayload.decodedAssetConfigParameters),
            groupId = rawTransactionPayload.groupId
        )
    }
}
