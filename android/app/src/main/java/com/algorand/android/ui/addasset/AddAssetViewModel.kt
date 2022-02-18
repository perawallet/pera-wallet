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

package com.algorand.android.ui.addasset

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.paging.CombinedLoadStates
import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.cachedIn
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.Result
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AssetAdditionUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import kotlin.properties.Delegates
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.ConflatedBroadcastChannel
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

class AddAssetViewModel @ViewModelInject constructor(
    private val assetRepository: AssetRepository,
    private val transactionsRepository: TransactionsRepository,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val assetAdditionUseCase: AssetAdditionUseCase
) : BaseViewModel() {

    var queryText: String by Delegates.observable("", { _, _, newValue ->
        queryChannel.offer(Pair(newValue, queryType))
    })

    var queryType: AssetQueryType by Delegates.observable(AssetQueryType.VERIFIED, { _, oldValue, newValue ->
        if (oldValue != newValue) {
            queryChannel.offer(Pair(queryText, newValue))
        }
    })

    val queryChannel = ConflatedBroadcastChannel<Pair<String, AssetQueryType>>()
    val sendTransactionResultLiveData = MutableLiveData<Event<Resource<Unit>>>()

    private lateinit var networkErrorMessage: String

    private var sendTransactionJob: Job? = null

    private var assetSearchDataSource: AssetSearchDataSource? = null

    init {
        queryChannel.asFlow()
            .debounce(QUERY_DEBOUNCE)
            .onEach { assetSearchDataSource?.invalidate() }
            .flowOn(Dispatchers.Default)
            .launchIn(viewModelScope)
    }

    fun start(networkErrorMessage: String) {
        this.networkErrorMessage = networkErrorMessage
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        account: Account
    ) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            when (val result = transactionsRepository.sendSignedTransaction(signedTransactionData)) {
                is Result.Success -> {
                    assetAdditionUseCase.addAssetAdditionToAccountCache(account.address, assetInformation)
                    sendTransactionResultLiveData.postValue(Event(Resource.Success(Unit)))
                }
                is Result.Error -> {
                    sendTransactionResultLiveData.postValue(Event(result.getAsResourceError()))
                }
            }
        }
    }

    // TODO: 11.02.2022 We can move this flow to use case level and get it from there
    val assetSearchPaginationFlow = Pager(
        PagingConfig(pageSize = SEARCH_RESULT_LIMIT, prefetchDistance = PREFETCH_DISTANCE, enablePlaceholders = false)
    ) {
        AssetSearchDataSource(
            assetRepository = assetRepository,
            currentQuery = queryChannel.valueOrNull ?: Pair("", AssetQueryType.VERIFIED),
            ::onAssetsLoaded
        ).also {
            assetSearchDataSource = it
        }
    }.flow.cachedIn(viewModelScope)

    private suspend fun onAssetsLoaded(assetList: List<AssetQueryItem>) {
        val assetCacheResultList = assetList.map {
            CacheResult.Success.create(it)
        }
        simpleAssetDetailUseCase.cacheAssets(assetCacheResultList)
    }

    fun createAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): AssetAdditionLoadStatePreview {
        return assetAdditionUseCase.createAssetAdditionLoadStatePreview(combinedLoadStates, itemCount, isLastStateError)
    }

    fun refreshTransactionHistory() {
        assetSearchDataSource?.invalidate()
    }

    companion object {
        const val SEARCH_RESULT_LIMIT = 50

        private const val PREFETCH_DISTANCE = 25
        private const val QUERY_DEBOUNCE = 400L
    }
}
