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

package com.algorand.android.modules.walletconnect.client.v1.domain.usecase

import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionAccountDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject
import javax.inject.Named

class InsertWalletConnectV1SessionToDBUseCase @Inject constructor(
    @Named(WalletConnectRepository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectRepository,
    private val walletConnectSessionDtoMapper: WalletConnectSessionDtoMapper,
    private val sessionAccountDtoMapper: WalletConnectSessionAccountDtoMapper
) {

    suspend operator fun invoke(settle: WalletConnect.Session.Settle.Result) {
        val sessionMeta = settle.session.sessionMeta as WalletConnect.Session.Meta.Version1
        val walletConnectSessionDto = walletConnectSessionDtoMapper.mapToSessionDto(settle, sessionMeta)
        val sessionId = settle.session.sessionIdentifier.getIdentifier().toLong()
        val connectedAddressDtoList = settle.session.connectedAccounts.map { connectedAccount ->
            sessionAccountDtoMapper.mapToSessionAccountDto(sessionId, connectedAccount.accountAddress)
        }
        walletConnectRepository.insertConnectedWalletConnectSession(walletConnectSessionDto, connectedAddressDtoList)
    }
}
