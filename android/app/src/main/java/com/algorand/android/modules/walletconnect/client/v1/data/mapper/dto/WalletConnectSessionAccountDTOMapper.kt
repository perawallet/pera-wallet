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

package com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto

import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionAccountEntity
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionAccountDTO
import javax.inject.Inject

class WalletConnectSessionAccountDTOMapper @Inject constructor() {

    fun mapToSessionAccountDTO(entity: WalletConnectSessionAccountEntity): WalletConnectSessionAccountDTO {
        return with(entity) {
            WalletConnectSessionAccountDTO(
                sessionId = sessionId,
                connectedAccountsAddress = connectedAccountsAddress
            )
        }
    }

    fun mapToSessionAccountDTO(sessionId: Long, connectedAddress: String): WalletConnectSessionAccountDTO {
        return WalletConnectSessionAccountDTO(
            sessionId = sessionId,
            connectedAccountsAddress = connectedAddress
        )
    }
}
