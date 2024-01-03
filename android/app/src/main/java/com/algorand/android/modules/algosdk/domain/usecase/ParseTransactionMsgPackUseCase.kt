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

package com.algorand.android.modules.algosdk.domain.usecase

import com.algorand.android.modules.algosdk.data.service.AlgorandSDKUtils
import com.algorand.android.modules.algosdk.domain.mapper.AlgorandAddressMapper
import com.algorand.android.modules.algosdk.domain.mapper.rawtransaction.RawTransactionDTOMapper
import com.algorand.android.modules.algosdk.domain.model.AlgorandAddress
import com.algorand.android.modules.algosdk.domain.model.RawTransaction
import javax.inject.Inject
import javax.inject.Named

class ParseTransactionMsgPackUseCase @Inject constructor(
    @Named(AlgorandSDKUtils.INJECTION_NAME)
    private val algorandSDKUtils: AlgorandSDKUtils,
    private val rawTransactionMapper: RawTransactionDTOMapper,
    private val algorandAddressMapper: AlgorandAddressMapper
) {

    fun parse(transactionMsgPack: ByteArray): RawTransaction? {
        val rawTransactionDto = algorandSDKUtils.parseRawTransaction(transactionMsgPack) ?: return null
        return rawTransactionMapper.mapToRawTransaction(
            transactionDto = rawTransactionDto,
            receiverAddress = createAddressFromPublicKey(rawTransactionDto.receiverAddress),
            senderAddress = createAddressFromPublicKey(rawTransactionDto.senderAddress),
            closeToAddress = createAddressFromPublicKey(rawTransactionDto.closeToAddress),
            rekeyAddress = createAddressFromPublicKey(rawTransactionDto.rekeyAddress),
            assetCloseToAddress = createAddressFromPublicKey(rawTransactionDto.assetCloseToAddress),
            assetReceiverAddress = createAddressFromPublicKey(rawTransactionDto.assetReceiverAddress)
        )
    }

    private fun createAddressFromPublicKey(publicKeyBase64: String?): AlgorandAddress? {
        if (publicKeyBase64 == null) return null
        val algorandAddressDTO = algorandSDKUtils.generateAccountAddressFromPublicKey(publicKeyBase64) ?: return null
        return algorandAddressMapper.mapToAlgorandAddress(algorandAddressDTO)
    }
}
