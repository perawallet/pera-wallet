@file:SuppressWarnings("TooManyFunctions")

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
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AssetStatus.PENDING_FOR_REMOVAL
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.repository.AccountRepository
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.exceptions.AccountNotFoundException
import com.algorand.android.utils.extensions.getAssetHoldingOrNull
import com.algorand.android.utils.extensions.getAssetStatusOrNull
import com.algorand.android.utils.isRekeyedToAnotherAccount
import com.algorand.android.utils.recordException
import com.algorand.android.utils.toShortenedAddress
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull

class AccountDetailUseCase @Inject constructor(
    private val accountRepository: AccountRepository,
    private val accountInformationUseCase: AccountInformationUseCase,
    private val accountManager: AccountManager,
    private val accountSummaryMapper: AccountSummaryMapper,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase
) : BaseUseCase() {

    fun getAccountDetailCacheFlow() = accountRepository.getAccountDetailCacheFlow()

    fun getAccountDetailCacheFlow(publicKey: String): Flow<CacheResult<AccountDetail>?> {
        return accountRepository.getAccountDetailCacheFlow()
            .mapNotNull { it.getOrDefault(publicKey, null) }
            .distinctUntilChanged()
    }

    fun getCachedAccountDetails() = getAccountDetailCacheFlow().value.values

    fun getCachedStandardAccountDetails() = getAccountDetailCacheFlow().value.values.filter {
        it.data?.account?.detail is Account.Detail.Standard
    }

    fun getCachedAccountDetail(publicKey: String): CacheResult<AccountDetail>? {
        return accountRepository.getCachedAccountDetail(publicKey)
    }

    suspend fun fetchAndCacheAccountDetail(
        accountAddress: String,
        scope: CoroutineScope
    ): Flow<CacheResult<AccountDetail>> = flow {
        accountInformationUseCase.getAccountInformationAndFetchAssets(accountAddress, scope).use(
            onSuccess = { accountInformation ->
                val localAccount = accountManager.getAccount(accountAddress) ?: run {
                    emit(CacheResult.Error.create(AccountNotFoundException()))
                    recordException(AccountNotFoundException())
                    return@use
                }
                val cacheResult = CacheResult.Success.create(AccountDetail(localAccount, accountInformation))
                accountRepository.cacheAccountDetail(cacheResult)
                emit(cacheResult)
            },
            onFailed = { exception, code ->
                emit(CacheResult.Error.create(exception, code))
            }
        )
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

    fun isAssetOwnedByAccount(publicKey: String, assetId: Long): Boolean {
        return getCachedAccountDetail(publicKey)?.data?.accountInformation?.getAllAssetIds()?.contains(assetId) ?: false
    }

    fun isAssetPendingForRemovalFromAccount(accountAddress: String, assetId: Long): Boolean {
        return getCachedAccountDetail(accountAddress)?.data?.getAssetStatusOrNull(assetId) == PENDING_FOR_REMOVAL
    }

    fun isAssetBalanceZero(publicKey: String, assetId: Long): Boolean? {
        getCachedAccountDetail(publicKey)?.let { account ->
            account.data?.getAssetHoldingOrNull(assetId)?.let {
                return it.amount == BigInteger.ZERO
            }
        } ?: return null
    }

    fun isAssetOwnedByAnyAccount(assetId: Long): Boolean {
        return getCachedAccountDetails().any {
            it.data?.accountInformation?.getAllAssetIds()?.contains(assetId) ?: false
        }
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
        return when (account?.type) {
            Account.Type.LEDGER, Account.Type.REKEYED_AUTH -> true
            Account.Type.STANDARD -> (account.getSecretKey() ?: byteArrayOf()).isNotEmpty()
            Account.Type.REKEYED -> isAuthAccountInDevice(account.address)
            Account.Type.WATCH, null -> false
        }
    }

    private fun isAuthAccountInDevice(accountAddress: String): Boolean {
        val accountAuthAddress = getAuthAddress(accountAddress) ?: return false
        val authAccountDetail = getCachedAccountDetail(accountAuthAddress)?.data ?: return false
        if (canAccountSignTransaction(authAccountDetail.account.address)) {
            return true
        }
        return false
    }

    suspend fun fetchAccountDetail(account: Account): Flow<DataResource<AccountDetail>> {
        return accountInformationUseCase.getAccountInformation(account.address).map { accountInformationData ->
            when (accountInformationData) {
                is DataResource.Success -> {
                    val accountDetail = AccountDetail(
                        account = account,
                        accountInformation = accountInformationData.data,
                        nameServiceName = getAccountNameService(account.address)
                    )
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

    fun getAccountSummaryFlow(publicKey: String): Flow<AccountDetailSummary> {
        return getAccountDetailCacheFlow(publicKey).map {
            val accountDetail = it?.data
            accountSummaryMapper.mapToAccountDetailSummary(
                canSignTransaction = canAccountSignTransaction(publicKey),
                accountType = accountDetail?.account?.type,
                accountAddress = publicKey,
                accountDisplayName = getAccountDisplayNameUseCase.invoke(publicKey)
            )
        }
    }

    fun getAccountType(publicKey: String): Account.Type? {
        return accountManager.getAccount(publicKey)?.type
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

    fun getAccountIcon(publicKey: String): AccountIconResource {
        return AccountIconResource.getAccountIconResourceByAccountType(accountManager.getAccount(publicKey)?.type)
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

    fun isThereAnyCachedErrorAccount(excludeWatchAccounts: Boolean): Boolean {
        val accountDetailCache = getAccountDetailCacheFlow().value
        return accountDetailCache.any { cachedAccount ->
            cachedAccount.value is CacheResult.Error<*> &&
                cachedAccount.value.data == null &&
                (canAccountSignTransaction(cachedAccount.key) || excludeWatchAccounts.not())
        }
    }

    fun isThereAnyCachedSuccessAccount(excludeWatchAccounts: Boolean): Boolean {
        val accountDetailCache = getAccountDetailCacheFlow().value
        return accountDetailCache.any { cachedAccount ->
            cachedAccount.value is CacheResult.Success<*> &&
                cachedAccount.value.data != null &&
                (canAccountSignTransaction(cachedAccount.key) || excludeWatchAccounts.not())
        }
    }

    fun isAccountCachedSuccessfully(accountAddress: String): Boolean {
        return accountRepository.getCachedAccountDetail(accountAddress) is CacheResult.Success
    }

    fun setAccountNameService(accountAddress: String, nameServiceName: String?) {
        accountRepository.getCachedAccountDetail(accountAddress)?.data?.nameServiceName = nameServiceName
    }

    private fun getAccountNameService(accountAddress: String): String? {
        return accountRepository.getCachedAccountDetail(accountAddress)?.data?.nameServiceName
    }

    fun getAuthAccount(accountAddress: String?): CacheResult<AccountDetail>? {
        val authAccountAddress = getAuthAddress(accountAddress ?: return null) ?: return null
        return getCachedAccountDetail(authAccountAddress)
    }

    fun getCachedAccountSecretKey(accountAddress: String?): ByteArray? {
        val safeAccountAddress = accountAddress ?: return null
        return getCachedAccountDetail(safeAccountAddress)?.data?.account?.getSecretKey()
    }
}
