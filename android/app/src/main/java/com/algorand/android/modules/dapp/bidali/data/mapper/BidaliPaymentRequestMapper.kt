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

package com.algorand.android.modules.dapp.bidali.data.mapper

import com.algorand.android.modules.dapp.bidali.data.model.BidaliPaymentRequest
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliPaymentRequestDTO
import javax.inject.Inject

@Suppress("ComplexCondition")
class BidaliPaymentRequestMapper @Inject constructor() {
    fun mapToBidaliPaymentRequestDTO(
        bidaliPaymentRequest: BidaliPaymentRequest
    ): BidaliPaymentRequestDTO? {
        return if (
            bidaliPaymentRequest.amount != null &&
            bidaliPaymentRequest.symbol != null &&
            bidaliPaymentRequest.protocol != null &&
            bidaliPaymentRequest.address != null &&
            bidaliPaymentRequest.chargeId != null &&
            bidaliPaymentRequest.extraId != null &&
            bidaliPaymentRequest.extraIdName != null &&
            bidaliPaymentRequest.description != null
        ) {
            BidaliPaymentRequestDTO(
                amount = bidaliPaymentRequest.amount,
                symbol = bidaliPaymentRequest.symbol,
                protocol = bidaliPaymentRequest.protocol,
                address = bidaliPaymentRequest.address,
                chargeId = bidaliPaymentRequest.chargeId,
                extraId = bidaliPaymentRequest.extraId,
                extraIdName = bidaliPaymentRequest.extraIdName,
                description = bidaliPaymentRequest.description,
            )
        } else {
            null
        }
    }
}
