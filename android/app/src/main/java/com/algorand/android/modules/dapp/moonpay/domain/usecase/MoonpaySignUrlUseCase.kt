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

package com.algorand.android.modules.dapp.moonpay.domain.usecase

import com.algorand.android.modules.dapp.moonpay.data.remote.model.SignMoonpayUrlRequest
import com.algorand.android.modules.dapp.moonpay.data.repository.MoonpayRepository
import com.algorand.android.utils.getDeeplinkUrl
import kotlinx.coroutines.flow.flow
import javax.inject.Inject

class MoonpaySignUrlUseCase @Inject constructor(
    private val moonpayRepository: MoonpayRepository
) {
    operator fun invoke(walletAddress: String) = flow {
        moonpayRepository.signMoonpayUrl(SignMoonpayUrlRequest(walletAddress, getDeeplinkUrl(walletAddress))).use(
            onSuccess = {
                emit(it)
            }
        )
    }
}
