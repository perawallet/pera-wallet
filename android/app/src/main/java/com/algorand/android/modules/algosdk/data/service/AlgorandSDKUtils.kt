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

package com.algorand.android.modules.algosdk.data.service

import com.algorand.android.modules.algosdk.data.model.AlgorandAddressDTO
import com.algorand.android.modules.algosdk.data.model.PendingTransactionResponseDTO
import com.algorand.android.modules.algosdk.domain.model.dto.RawTransactionDTO

interface AlgorandSDKUtils {

    suspend fun waitForConfirmation(txnId: String, maxRoundToWait: Int): PendingTransactionResponseDTO

    fun parseRawTransaction(txnByteArray: ByteArray): RawTransactionDTO?

    fun generateAccountAddressFromPublicKey(addressBase64: String): AlgorandAddressDTO?

    companion object {
        const val INJECTION_NAME = "algorandSDKUtilsInjectionName"
    }
}
