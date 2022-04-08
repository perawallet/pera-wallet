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
import androidx.lifecycle.viewModelScope
import androidx.paging.cachedIn
import com.algorand.android.models.AssetQueryType
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AssetAdditionUseCase
import kotlin.properties.Delegates

class AddAssetViewModel @ViewModelInject constructor(
    private val addAssetPreviewUseCase: AddAssetPreviewUseCase,
    transactionsRepository: TransactionsRepository,
    assetAdditionUseCase: AssetAdditionUseCase,
    accountDetailUseCase: AccountDetailUseCase
) : BaseAddAssetViewModel(transactionsRepository, assetAdditionUseCase, accountDetailUseCase) {

    var queryText: String by Delegates.observable("", { _, _, newValue ->
        addAssetPreviewUseCase.searchAsset(newValue, queryType)
    })

    var queryType: AssetQueryType by Delegates.observable(AssetQueryType.VERIFIED, { _, oldValue, newValue ->
        if (oldValue != newValue) {
            addAssetPreviewUseCase.searchAsset(queryText, newValue)
        }
    })

    override val searchPaginationFlow = addAssetPreviewUseCase
        .getSearchPaginationFlow(assetSearchPagerBuilder, viewModelScope, queryText, queryType)
        .cachedIn(viewModelScope)

    fun refreshTransactionHistory() {
        addAssetPreviewUseCase.invalidateDataSource()
    }
}
