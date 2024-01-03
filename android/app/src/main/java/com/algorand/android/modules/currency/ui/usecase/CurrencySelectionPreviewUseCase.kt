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

package com.algorand.android.modules.currency.ui.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.CurrencySelectionPreviewMapper
import com.algorand.android.models.ui.CurrencySelectionPreview
import com.algorand.android.modules.currency.domain.model.CurrencyOption
import com.algorand.android.modules.currency.domain.usecase.CurrencyOptionUseCase
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.currency.ui.mapper.CurrencyListItemMapper
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class CurrencySelectionPreviewUseCase @Inject constructor(
    private val currencyListItemMapper: CurrencyListItemMapper,
    private val currencySelectionPreviewMapper: CurrencySelectionPreviewMapper,
    private val currencyUseCase: CurrencyUseCase,
    private val currencyOptionUseCase: CurrencyOptionUseCase
) : BaseUseCase() {

    suspend fun getCurrencySelectionPreviewFlow(query: String): Flow<CurrencySelectionPreview> {
        return getCurrencyListFlow(query).map { assetList ->
            currencySelectionPreviewMapper.mapToCurrencySelectionPreview(
                dataResource = assetList,
                isLoading = assetList is DataResource.Loading,
                isError = assetList is DataResource.Error
            )
        }
    }

    private suspend fun getCurrencyListFlow(query: String): Flow<DataResource<List<CurrencyListItem>>> {
        return currencyOptionUseCase.getCurrencyOptionListFlow().map { dataResource ->
            when (dataResource) {
                is DataResource.Success -> {
                    val queryFilteredList = dataResource.data.filter { currency ->
                        val isIdContainsQuery = currency.currencyId.contains(query, true)
                        val isNameContainsQuery = currency.currencyName.contains(query, true)
                        isIdContainsQuery || isNameContainsQuery
                    }
                    val currencyListItems = createCurrencyListItems(queryFilteredList)
                    DataResource.Success(currencyListItems)
                }
                is DataResource.Error.Api -> DataResource.Error.Api(dataResource.exception, dataResource.code)
                is DataResource.Error.Local -> DataResource.Error.Local(dataResource.exception)
                is DataResource.Loading -> DataResource.Loading()
            }
        }
    }

    private fun createCurrencyListItems(
        currencyOptionList: List<CurrencyOption>
    ): List<CurrencyListItem> {
        val algoCurrencyListItem = currencyListItemMapper.createAlgoCurrencyListItem(
            isSelected = currencyUseCase.isPrimaryCurrencyAlgo()
        )
        return mutableListOf<CurrencyListItem>().apply {
            add(algoCurrencyListItem)
            currencyOptionList.forEach { currencyOption ->
                val currencyListItem = currencyListItemMapper.mapToCurrencyListItem(
                    currencyOption = currencyOption,
                    isSelectedItem = getSelectedCurrencyId() == currencyOption.currencyId
                )
                add(currencyListItem)
            }
        }
    }

    private fun getSelectedCurrencyId() = currencyUseCase.getPrimaryCurrencyId()
}
