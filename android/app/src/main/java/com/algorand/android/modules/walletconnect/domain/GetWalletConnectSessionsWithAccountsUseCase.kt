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

package com.algorand.android.modules.walletconnect.domain

import com.algorand.android.mapper.WalletConnectSessionEntityMapper
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.repository.WalletConnectRepository
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.mapNotNull

class GetWalletConnectSessionsWithAccountsUseCase @Inject constructor(
    private val walletConnectRepository: WalletConnectRepository,
    private val walletConnectSessionEntityMapper: WalletConnectSessionEntityMapper,
    private val getConnectedAccountsOfWalletConnectSessionUseCase: GetConnectedAccountsOfWalletConnectSessionUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) {

    operator fun invoke(): Flow<List<WalletConnectSession>> {
        val flow = walletConnectRepository.getAllWalletConnectSessionWithAccountAddresses()
        return flow.mapNotNull { wcSessionsWithAccounts ->
            wcSessionsWithAccounts?.map { wcSessionsWithAccount ->
                val wcSessionAccounts = getConnectedAccountsOfWalletConnectSessionUseCase(
                    wcSessionsWithAccount.walletConnectSessions
                )
                val accountsName = wcSessionAccounts.map {
                    accountDetailUseCase.getAccountName(it.connectedAccountsAddress)
                }
                val accountsAddresses = wcSessionAccounts.map { it.connectedAccountsAddress }
                walletConnectSessionEntityMapper.mapFromEntity(
                    entity = wcSessionsWithAccount.walletConnectSessions,
                    accountsNames = accountsName,
                    connectedAccountsAddresses = accountsAddresses
                )
            }
        }
    }
}
