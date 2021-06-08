/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.assetdetail

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MediatorLiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.PagingData
import androidx.paging.cachedIn
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.ContactDao
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionListItem
import com.algorand.android.models.TransactionsResponse
import com.algorand.android.models.User
import com.algorand.android.repository.AccountRepository
import com.algorand.android.repository.AccountRepository.Companion.DEFAULT_TRANSACTION_COUNT
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.createCSVFile
import com.algorand.android.utils.formatAsRFC3339Version
import com.algorand.android.utils.preference.isFilterTutorialShown
import com.algorand.android.utils.preference.isRewardsActivated
import com.algorand.android.utils.preference.setFilterTutorialShown
import com.algorand.android.utils.toListItems
import java.io.File
import java.math.BigInteger
import java.time.ZonedDateTime
import kotlin.properties.Delegates
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

class AssetDetailViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val accountManager: AccountManager,
    private val sharedPref: SharedPreferences,
    private val accountRepository: AccountRepository,
    private val contactDao: ContactDao
) : BaseViewModel() {

    val csvFileLiveData = MutableLiveData<Event<Resource<File>>>()

    val dateFilterLiveData = MutableLiveData<DateFilter>(DateFilter.AllTime)

    var balanceLiveData: LiveData<BigInteger?>? = null

    val assetFilterLiveData = MutableLiveData<AssetInformation>()

    private val pendingListLiveData = MutableLiveData<List<BaseTransactionListItem>>()

    private var contactListFlow = MutableStateFlow<List<User>?>(null)

    init {
        viewModelScope.launch {
            contactDao.getAllAsFlow().collectLatest { contactList ->
                contactListFlow.value = contactList
            }
        }
    }

    fun getPendingDateAwareList() = MediatorLiveData<List<BaseTransactionListItem>>().apply {
        fun update() {
            val pendingHistory = pendingListLiveData.value.orEmpty()
            val assetInformation = assetFilterLiveData.value
            value = when (val dateFilter = dateFilterLiveData.value) {
                DateFilter.Today, DateFilter.AllTime -> {
                    pendingHistory.filter { (it as TransactionListItem).assetId == assetInformation?.assetId }
                }
                DateFilter.Yesterday,
                DateFilter.LastMonth,
                DateFilter.LastWeek,
                null -> {
                    emptyList()
                }
                is DateFilter.CustomRange -> {
                    if (dateFilter.customDateRange?.to?.isAfter(ZonedDateTime.now()) == true) {
                        pendingHistory.filter { (it as TransactionListItem).assetId == assetInformation?.assetId }
                    } else {
                        emptyList()
                    }
                }
            }
        }
        addSource(pendingListLiveData) { update() }
        addSource(assetFilterLiveData) { update() }
        addSource(dateFilterLiveData) { update() }
    }

    var transactionPaginationFlow: Flow<PagingData<BaseTransactionListItem>>? = null

    var isPendingTransactionPollingActive by Delegates.observable(false, { _, _, newValue ->
        if (newValue) {
            activatePendingTransactionsPolling()
        } else {
            pendingTransactionPolling?.cancel()
        }
    })

    private lateinit var assetInformation: AssetInformation
    private lateinit var address: String

    private var pendingTransactionPolling: Job? = null

    var transactionHistoryDataSource: TransactionsDataSource? = null

    fun start(address: String, assetInformation: AssetInformation) {
        this.address = address
        this.assetInformation = assetInformation
        setupBalanceLiveData(address)
        setupTransactionPaginationFlow(address)
    }

    private fun setupTransactionPaginationFlow(address: String) {
        if (transactionHistoryDataSource == null) {
            transactionPaginationFlow = Pager(PagingConfig(pageSize = DEFAULT_TRANSACTION_COUNT)) {
                TransactionsDataSource(
                    pendingListLiveData,
                    accountRepository,
                    address,
                    assetInformation.assetId,
                    assetInformation.decimals,
                    accountManager.getAccounts(),
                    contactListFlow.value.orEmpty(),
                    sharedPref.isRewardsActivated(),
                    dateFilterLiveData.value?.getDateRange()
                ).also {
                    transactionHistoryDataSource = it
                }
            }.flow.cachedIn(viewModelScope)
        } else {
            transactionHistoryDataSource?.invalidate()
        }
    }

    fun createCSVForList(cacheDirectory: File, accountName: String) {
        csvFileLiveData.postValue(Event(Resource.Loading))
        viewModelScope.launch(Dispatchers.IO) {
            var nextToken: String? = null
            var exception: Exception? = null
            val transactionList = mutableListOf<Transaction>()
            val currentDataRange = dateFilterLiveData.value?.getDateRange()
            while (isActive) {
                getTransactions(nextToken, currentDataRange).use(
                    onSuccess = {
                        transactionList.addAll(it.transactionList)
                        nextToken = it.nextToken
                    }, onFailed = {
                        exception = it
                        nextToken = null
                    }
                )
                if (nextToken == null) break
            }
            if (transactionList.isEmpty() && exception != null) {
                csvFileLiveData.postValue(Event(Resource.Error.Api(exception!!)))
            } else {
                val csvFile = transactionList.createCSVFile(
                    cacheDir = cacheDirectory,
                    assetId = assetInformation.assetId,
                    decimal = assetInformation.decimals,
                    accountName = accountName,
                    userAddress = address,
                    dateRange = currentDataRange
                )
                csvFileLiveData.postValue(Event(Resource.Success(csvFile)))
            }
        }
    }

    private suspend fun getTransactions(
        nextToken: String? = null,
        dateRange: DateRange?
    ): Result<TransactionsResponse> {
        return accountRepository.getTransactions(
            assetInformation.assetId,
            address,
            fromDate = dateRange?.from.formatAsRFC3339Version(),
            toDate = dateRange?.to.formatAsRFC3339Version(),
            nextToken = nextToken,
            limit = null
        )
    }

    fun isFilterTooltipShown() = sharedPref.isFilterTutorialShown()

    fun setFilterTooltipShown() = sharedPref.setFilterTutorialShown()

    private fun setupBalanceLiveData(address: String) {
        balanceLiveData = accountCacheManager.getBalanceFlow(address, assetInformation.assetId).asLiveData()
    }

    private fun activatePendingTransactionsPolling() {
        pendingTransactionPolling = viewModelScope.launch(Dispatchers.IO) {
            while (true) {
                accountRepository.getPendingTransactions(address).use(
                    onSuccess = { pendingTransactionsResponse ->
                        pendingTransactionsResponse.pendingTransactions?.let { pendingTransactionList ->
                            pendingTransactionList.ifEmpty {
                                pendingListLiveData.postValue(emptyList())
                                return@use
                            }

                            val wrappedPendingListItems =
                                pendingTransactionList.toListItems(
                                    assetInformation.assetId,
                                    assetInformation.decimals,
                                    address,
                                    accountManager.getAccounts(),
                                    contactListFlow.value.orEmpty(),
                                    sharedPref.isRewardsActivated()
                                )

                            synchronized(pendingListLiveData) {
                                val (isListChanged, newRefreshedList) = mergePendingToList(wrappedPendingListItems)

                                if (isListChanged) {
                                    pendingListLiveData.postValue(newRefreshedList)
                                }
                            }
                        }
                    }
                )
                delay(PENDING_TRANSACTION_DELAY)
            }
        }
    }

    private fun mergePendingToList(
        newPendingList: MutableList<BaseTransactionListItem>
    ): Pair<Boolean, MutableList<BaseTransactionListItem>> {
        val currentPendingTransactionList = pendingListLiveData.value ?: mutableListOf()
        var isListChanged = false
        val result = currentPendingTransactionList.toMutableList()

        newPendingList.forEach { newPendingItem ->
            // Check if transaction with same id is in the list before.
            val isThereAnyTransactionWithSameId = currentPendingTransactionList.any { transactionItem ->
                transactionItem.isSame(newPendingItem)
            }
            if (isThereAnyTransactionWithSameId.not()) {
                result.add(0, newPendingItem)
                isListChanged = true
            }
        }
        return Pair(isListChanged, result)
    }

    companion object {
        private const val PENDING_TRANSACTION_DELAY = 800L
    }
}
