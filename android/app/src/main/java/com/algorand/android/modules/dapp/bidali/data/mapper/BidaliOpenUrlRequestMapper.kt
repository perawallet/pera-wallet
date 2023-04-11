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

import com.algorand.android.modules.dapp.bidali.data.model.BidaliOpenUrlRequest
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliOpenUrlRequestDTO
import javax.inject.Inject

@Suppress("ComplexCondition")
class BidaliOpenUrlRequestMapper @Inject constructor() {
    fun mapToBidaliOpenUrlRequestDTO(
        bidaliOpenUrlRequest: BidaliOpenUrlRequest
    ): BidaliOpenUrlRequestDTO? {
        return if (bidaliOpenUrlRequest.url != null) {
            BidaliOpenUrlRequestDTO(
                url = bidaliOpenUrlRequest.url
            )
        } else {
            null
        }
    }
}
