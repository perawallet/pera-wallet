/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.accountdetail.assets.search

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.Result
import com.algorand.android.usecase.AssetSearchUseCase
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

class AssetSearchViewModel @ViewModelInject constructor(
    private val assetSearchUseCase: AssetSearchUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val publicKey = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)

    private val _accountAssetFlow = MutableStateFlow<Resource<List<AccountDetailAssetsItem>>>(Resource.Loading)
    val accountAssetFlow: StateFlow<Resource<List<AccountDetailAssetsItem>>> get() = _accountAssetFlow

    private val searchQueryFlow = MutableStateFlow("")

    init {
        viewModelScope.launch {
            searchQueryFlow
                .debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query -> assetSearchUseCase.fetchAccountAssets(publicKey, query) }
                .collectLatest {
                    when (it) {
                        is Result.Error -> _accountAssetFlow.emit(it.getAsResourceError())
                        is Result.Success -> _accountAssetFlow.emit(Resource.Success(it.data))
                    }
                }
        }
    }

    fun onFilterListByQuery(query: String) {
        viewModelScope.launch {
            searchQueryFlow.emit(query)
        }
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
        private const val PUBLIC_KEY = "publicKey"
    }
}
