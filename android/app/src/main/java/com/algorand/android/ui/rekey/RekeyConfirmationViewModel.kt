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

package com.algorand.android.ui.rekey

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.MIN_FEE
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logRekeyEvent
import com.google.firebase.analytics.FirebaseAnalytics
import kotlin.math.max
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class RekeyConfirmationViewModel @ViewModelInject constructor(
    private val firebaseAnalytics: FirebaseAnalytics,
    private val accountManager: AccountManager,
    private val accountCacheManager: AccountCacheManager,
    private val transactionsRepository: TransactionsRepository
) : BaseViewModel() {

    private var sendTransactionJob: Job? = null

    val feeLiveData = MutableLiveData<Long>()
    val transactionResourceLiveData = MutableLiveData<Event<Resource<Any>>>()

    init {
        getFee()
    }

    private fun getFee() {
        viewModelScope.launch(Dispatchers.IO) {
            transactionsRepository.getTransactionParams().use(
                onSuccess = { params ->
                    feeLiveData.postValue(max(REKEY_BYTE_ARRAY_SIZE * params.fee, params.minFee ?: MIN_FEE))
                }
            )
        }
    }

    fun sendRekeyTransaction(transactionDetail: SignedTransactionDetail.RekeyOperation) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            transactionsRepository.sendSignedTransaction(transactionDetail.signedTransactionData).use(
                onSuccess = {
                    with(transactionDetail) {
                        val newRekeyedAuthDetailMap = mutableMapOf<String, Account.Detail.Ledger>().apply {
                            if (accountCacheData.account.detail is Account.Detail.RekeyedAuth) {
                                putAll(accountCacheData.account.detail.rekeyedAuthDetail)
                            }
                            put(rekeyAdminAddress, ledgerDetail)
                        }
                        val authAccount = Account.create(
                            publicKey = accountCacheData.account.address,
                            detail = Account.Detail.RekeyedAuth.create(
                                accountCacheData.getAuthTypeAndDetail(),
                                newRekeyedAuthDetailMap
                            ),
                            accountName = accountCacheData.account.name
                        )
                        accountManager.addNewAccount(authAccount)
                    }
                    firebaseAnalytics.logRekeyEvent()
                    transactionResourceLiveData.postValue(Event(Resource.Success(Any())))
                },
                onFailed = { exception, _ ->
                    transactionResourceLiveData.postValue(Event(Resource.Error.Api(exception)))
                }
            )
        }
    }

    fun getAccountCacheData(address: String): AccountCacheData? {
        return accountCacheManager.accountCacheMap.value[address]
    }

    fun getCachedAccountName(address: String): String? {
        return accountCacheManager.accountCacheMap.value[address]?.account?.name
    }

    fun getCachedAccountAuthAddress(address: String): String? {
        return accountCacheManager.accountCacheMap.value[address]?.authAddress
    }

    fun getCachedAccountData(address: String): Account? {
        return accountCacheManager.accountCacheMap.value[address]?.account
    }

    companion object {
        private const val REKEY_BYTE_ARRAY_SIZE = 30
    }
}
