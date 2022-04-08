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

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AssetAdditionUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch

abstract class BaseAddAssetViewModel(
    private val transactionsRepository: TransactionsRepository,
    private val assetAdditionUseCase: AssetAdditionUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) : BaseViewModel() {

    private lateinit var networkErrorMessage: String

    protected abstract val searchPaginationFlow: Flow<PagingData<BaseAssetSearchListItem>>

    protected val assetSearchPagerBuilder = AssetSearchPagerBuilder.create()

    val assetSearchPaginationFlow
        get() = searchPaginationFlow

    val sendTransactionResultLiveData = MutableLiveData<Event<Resource<Unit>>>()

    private var sendTransactionJob: Job? = null

    fun start(networkErrorMessage: String) {
        this.networkErrorMessage = networkErrorMessage
    }

    fun createAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): AssetAdditionLoadStatePreview {
        return assetAdditionUseCase.createAssetAdditionLoadStatePreview(combinedLoadStates, itemCount, isLastStateError)
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        account: Account
    ) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        // TODO Create new UseCase to send signed transaction to blockchain
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

    fun isAssetOwnedByAccount(publicKey: String, assetId: Long): Boolean {
        return accountDetailUseCase.isAssetOwnedByAccount(publicKey, assetId)
    }

    companion object {
        const val SEARCH_RESULT_LIMIT = 50
    }
}
