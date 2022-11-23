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

import com.algorand.android.modules.algosdk.domain.model.RawTransactionType
import com.algorand.android.modules.algosdk.domain.model.dto.RawTransactionTypeDTO
import javax.inject.Inject

class RawTransactionTypeDTODecider @Inject constructor() {

    fun decideRawTransactionType(rawTransactionTypePayload: RawTransactionTypeDTO): RawTransactionType {
        return when (rawTransactionTypePayload) {
            RawTransactionTypeDTO.PAY_TRANSACTION -> RawTransactionType.PAY_TRANSACTION
            RawTransactionTypeDTO.ASSET_TRANSACTION -> RawTransactionType.ASSET_TRANSACTION
            RawTransactionTypeDTO.APP_TRANSACTION -> RawTransactionType.APP_TRANSACTION
            RawTransactionTypeDTO.ASSET_CONFIGURATION -> RawTransactionType.ASSET_CONFIGURATION
            RawTransactionTypeDTO.UNDEFINED -> RawTransactionType.UNDEFINED
        }
    }
}
