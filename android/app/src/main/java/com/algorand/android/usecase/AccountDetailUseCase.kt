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

package com.algorand.android.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.AccountSummaryMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.repository.AccountRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.isRekeyedToAnotherAccount
import com.algorand.android.utils.toShortenedAddress
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull

class AccountDetailUseCase @Inject constructor(
    private val accountRepository: AccountRepository,
    private val accountInformationUseCase: AccountInformationUseCase,
    private val accountManager: AccountManager,
    private val accountSummaryMapper: AccountSummaryMapper
) : BaseUseCase() {

    fun getAccountDetailCacheFlow() = accountRepository.getAccountDetailCacheFlow()

    fun getAccountDetailCacheFlow(publicKey: String): Flow<CacheResult<AccountDetail>?> {
        return accountRepository.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null) }
            .distinctUntilChanged()
    }

    fun getCachedAccountDetails() = getAccountDetailCacheFlow().value.values

    fun getCachedAccountDetail(publicKey: String): CacheResult<AccountDetail>? {
        return accountRepository.getCachedAccountDetail(publicKey)
    }

    suspend fun clearAccountDetailCache() {
        accountRepository.clearAccountDetailCache()
    }

    suspend fun cacheAccountDetail(accountDetail: CacheResult.Success<AccountDetail>) {
        accountRepository.cacheAccountDetail(accountDetail)
    }

    suspend fun cacheAccountDetail(accountPublicKey: String, accountDetail: CacheResult.Error<AccountDetail>) {
        accountRepository.cacheAccountDetail(accountPublicKey, accountDetail)
    }

    suspend fun cacheAccountDetails(accountDetailKeyValuePairList: List<Pair<String, CacheResult<AccountDetail>>>) {
        accountRepository.cacheAllAccountDetails(accountDetailKeyValuePairList)
    }

    fun areAllAccountsCached(): Boolean {
        return accountManager.accounts.value.size <= accountRepository.getAccountDetailCacheFlow().value.size
    }

    fun getCachedAccountsAssets(): Set<Long> {
        return accountRepository.getAccountDetailCacheFlow().value
            .mapNotNull { it.value.data?.accountInformation?.getAllAssetIds() }
            .flatten()
            .toSet()
    }

    fun getCachedAccountAlgoAmount(publicKey: String): BigInteger? {
        return accountRepository.getCachedAccountDetail(publicKey)?.data?.accountInformation?.amount
    }

    fun canAccountSignTransaction(publicKey: String): Boolean {
        val account = accountManager.getAccount(publicKey)
        return account?.type != null && account.type != Account.Type.WATCH && account.type != Account.Type.REKEYED
    }

    suspend fun fetchAccountDetail(account: Account): Flow<DataResource<AccountDetail>> {
        return accountInformationUseCase.getAccountInformation(account.address).map { accountInformationData ->
            when (accountInformationData) {
                is DataResource.Success -> {
                    val accountDetail = AccountDetail(account, accountInformationData.data)
                    DataResource.Success(accountDetail)
                }
                is DataResource.Error.Api -> {
                    DataResource.Error.Api(accountInformationData.exception, accountInformationData.code)
                }
                else -> DataResource.Loading()
            }
        }
    }

    private fun isAccountRekeyed(accountDetail: AccountDetail?): Boolean {
        return accountDetail?.run {
            !accountInformation.rekeyAdminAddress.isNullOrBlank() &&
                accountInformation.rekeyAdminAddress != account.address
        } == true
    }

    // TODO this function shouldn't return nullable model also it should be moved into its own UseCase
    fun getAccountSummary(publicKey: String): AccountDetailSummary? {
        val accountDetail = getCachedAccountDetail(publicKey)?.data ?: return null
        return accountSummaryMapper.mapTo(accountDetail, canAccountSignTransaction(publicKey))
    }

    fun getAccountType(publicKey: String): Account.Type {
        val account = accountRepository.getCachedAccountDetail(publicKey)?.data?.account
        return account?.type ?: Account.Type.STANDARD
    }

    fun getAccountName(publicKey: String): String {
        val account = accountRepository.getCachedAccountDetail(publicKey)?.data?.account
        val accountName = account?.name
        val accountAddress = account?.address
        return accountName?.ifEmpty { accountAddress.toShortenedAddress() }.orEmpty()
    }

    fun getAuthAddress(publicKey: String): String? {
        val accountInformation = accountRepository.getCachedAccountDetail(publicKey)?.data?.accountInformation
        return accountInformation?.rekeyAdminAddress
    }

    fun getAccountAddress(publicKey: String): String? {
        val accountInformation = accountRepository.getCachedAccountDetail(publicKey)?.data?.accountInformation
        return accountInformation?.address
    }

    fun isAccountRekeyed(publicKey: String): Boolean {
        val authAddress = accountRepository.getCachedAccountDetail(publicKey)
            ?.data
            ?.accountInformation
            ?.rekeyAdminAddress
        return isRekeyedToAnotherAccount(authAddress, publicKey)
    }

    fun isThereAnyAccountWithPublicKey(publicKey: String): Boolean {
        return accountManager.isThereAnyAccountWithPublicKey(publicKey)
    }
}
