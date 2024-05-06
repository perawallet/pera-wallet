/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.walletconnect.connectionrequest.domain.usecase

import com.algorand.android.modules.walletconnect.connectionrequest.domain.repository.WCDomainScammerStateRepository
import javax.inject.Inject
import javax.inject.Named

class WCDomainScammerStateUseCase @Inject constructor(
    @Named(WCDomainScammerStateRepository.INJECTION_NAME)
    private val wcDomainScammerStateRepository: WCDomainScammerStateRepository
) {
    suspend operator fun invoke(domain: String): Boolean {
        var isDomainScammer = false
        wcDomainScammerStateRepository.getDomainScammerState(domain).use(
            onSuccess = { response ->
                isDomainScammer = response.isScammer ?: false
            }
        )
        return isDomainScammer
    }
}
