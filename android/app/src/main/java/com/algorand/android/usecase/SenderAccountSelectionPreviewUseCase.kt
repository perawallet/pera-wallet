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
 */

package com.algorand.android.usecase

import com.algorand.android.mapper.SenderAccountSelectionPreviewMapper
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.Result
import com.algorand.android.models.SenderAccountSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class SenderAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val senderAccountSelectionPreviewMapper: SenderAccountSelectionPreviewMapper,
    private val senderAccountSelectionUseCase: SenderAccountSelectionUseCase
) {
    fun getInitialPreview(): SenderAccountSelectionPreview {
        return senderAccountSelectionPreviewMapper.mapToInitialPreview()
    }

    suspend fun getUpdatedPreviewWithAccountList(
        preview: SenderAccountSelectionPreview
    ): SenderAccountSelectionPreview {
        val accountList = getBaseNormalAccountListItems()
        return preview.copy(
            accountList = accountList,
            isEmptyStateVisible = accountList.isEmpty(),
            isLoading = false
        )
    }

    suspend fun getUpdatedPreviewWithAccountListAndSpecificAsset(
        assetId: Long,
        preview: SenderAccountSelectionPreview
    ): SenderAccountSelectionPreview {
        val accountList = getBaseNormalAccountListItemsFilteredByAssetId(assetId)
        return preview.copy(
            accountList = accountList,
            isEmptyStateVisible = accountList.isEmpty(),
            isLoading = false
        )
    }

    suspend fun getUpdatedPreviewFlowWithAccountInformation(
        fromAccountAddress: String,
        viewModelScope: CoroutineScope,
        preview: SenderAccountSelectionPreview
    ): Flow<SenderAccountSelectionPreview> = flow {
        emit(preview.copy(isLoading = true))
        val loadingFinishedPreview = preview.copy(isLoading = false)
        when (
            val result =
            senderAccountSelectionUseCase.fetchAccountInformation(fromAccountAddress, viewModelScope)
        ) {
            is Result.Error -> emit(loadingFinishedPreview.copy(fromAccountInformationErrorEvent = Event(result)))
            is Result.Success ->
                emit(loadingFinishedPreview.copy(fromAccountInformationSuccessEvent = Event(result.data)))
        }
    }

    private suspend fun getBaseNormalAccountListItems(): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase.createAccountSelectionListAccountItemsWhichCanSignTransaction(
            showHoldings = true,
            showFailedAccounts = true
        )
    }

    private suspend fun getBaseNormalAccountListItemsFilteredByAssetId(
        assetId: Long
    ): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase
            .createAccountSelectionListAccountItemsFilteredByAssetIdWhichCanSignTransaction(
                assetId = assetId,
                showHoldings = true,
                showFailedAccounts = true
            )
    }
}
