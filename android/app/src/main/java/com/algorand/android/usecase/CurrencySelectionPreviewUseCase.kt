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

import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.CurrencyListItemMapper
import com.algorand.android.mapper.CurrencySelectionPreviewMapper
import com.algorand.android.models.Currency
import com.algorand.android.models.CurrencyOption
import com.algorand.android.models.ui.CurrencySelectionPreview
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

    suspend fun getCurrencySelectionPreviewFlow(): Flow<CurrencySelectionPreview> {
        return getCurrencyListFlow().map { assetList ->
            currencySelectionPreviewMapper.mapToCurrencySelectionPreview(
                dataResource = assetList,
                isLoading = assetList is DataResource.Loading,
                isError = assetList is DataResource.Error
            )
        }
    }

    private suspend fun getCurrencyListFlow(): Flow<DataResource<List<CurrencyListItem>>> {
        return currencyOptionUseCase.getCurrencyOptionListFlow().map {
            when (it) {
                is DataResource.Success -> DataResource.Success(createCurrencyListItems(it))
                is DataResource.Error.Api -> DataResource.Error.Api(it.exception, it.code)
                is DataResource.Error.Local -> DataResource.Error.Local(it.exception)
                is DataResource.Loading -> DataResource.Loading()
            }
        }
    }

    private fun createCurrencyListItems(
        currencyOptionList: DataResource.Success<List<CurrencyOption>>
    ): List<CurrencyListItem> {
        val currencyListItems = currencyOptionList.data.map { currencyOption ->
            currencyListItemMapper.mapToCurrencyListItem(
                currencyOption = currencyOption,
                isSelectedItem = getSelectedCurrencyId() == currencyOption.id
            )
        }.toMutableList()
        currencyListItems.add(
            0,
            currencyListItemMapper.createAlgoCurrencyListItem(getSelectedCurrencyId() == Currency.ALGO.id)
        )
        return currencyListItems.toList()
    }

    private fun getSelectedCurrencyId() = currencyUseCase.getSelectedCurrency()
}
