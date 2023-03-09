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

package com.algorand.android.utils.coremanager

import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.modules.fetchnameservices.domain.usecase.FetchGivenAccountsNameServicesUseCase
import com.algorand.android.modules.fetchnameservices.domain.usecase.SetGivenAccountsNameServicesNameUseCase
import com.algorand.android.modules.firebase.token.FirebaseTokenManager
import com.algorand.android.usecase.AccountCacheStatusUseCase
import com.algorand.android.usecase.GetLocalAccountsUseCase
import com.algorand.android.utils.DataResource
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged

/**
 * Helper class to manage local accounts name services continuously.
 * Should be provided by Hilt as Singleton
 */
class LocalAccountsNameServiceManager(
    private var firebaseTokenManager: FirebaseTokenManager,
    private val getLocalAccountsUseCase: GetLocalAccountsUseCase,
    private val fetchGivenAccountsNameServicesUseCase: FetchGivenAccountsNameServicesUseCase,
    private val setGivenAccountsNameServicesNameUseCase: SetGivenAccountsNameServicesNameUseCase,
    private val accountCacheStatusUseCase: AccountCacheStatusUseCase
) : BaseCacheManager() {

    private val localAccountsCollector: (List<Account>) -> Unit = {
        if (it.isNotEmpty()) startJob() else stopCurrentJob()
    }

    private val nodeSwitchCollector: (DataResource<Unit>?) -> Unit = {
        val localAccounts = getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache()
        if (it is DataResource.Success && localAccounts.isNotEmpty()) startJob()
    }

    override suspend fun initialize(coroutineScope: CoroutineScope) {
        initObservers()
    }

    override fun doBeforeJobStarts() {
        stopCurrentJob()
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        updateLocalAccountNameServices()
    }

    private suspend fun initObservers() {
        getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCacheAsFlow().collectLatest(localAccountsCollector)
        firebaseTokenManager.firebasePushTokenStatusFlow.collectLatest(nodeSwitchCollector)
    }

    private suspend fun updateLocalAccountNameServices() {
        val localAccountAddresses = getLocalAccountsUseCase.getLocalAccountsFromAccountManagerCache().map { it.address }
        combine(
            accountCacheStatusUseCase.getAccountCacheStatusFlow().distinctUntilChanged(),
            fetchGivenAccountsNameServicesUseCase.invoke(localAccountAddresses).distinctUntilChanged()
        ) { accountCacheStatus, nameServicesOfLocalAccounts ->
            if (accountCacheStatus == AccountCacheStatus.DONE && nameServicesOfLocalAccounts is DataResource.Success) {
                setGivenAccountsNameServicesNameUseCase.invoke(nameServicesOfLocalAccounts.data)
            }
        }.distinctUntilChanged().collect()
    }
}
