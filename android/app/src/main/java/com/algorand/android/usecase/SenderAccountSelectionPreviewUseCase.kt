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

import com.algorand.android.R
import com.algorand.android.mapper.SenderAccountSelectionPreviewMapper
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.Result
import com.algorand.android.models.SenderAccountSelectionPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.validator.AmountTransactionValidationUseCase
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class SenderAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val amountTransactionValidationUseCase: AmountTransactionValidationUseCase,
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
        when (val result =
            senderAccountSelectionUseCase.fetchAccountInformation(fromAccountAddress, viewModelScope)) {
            is Result.Error -> emit(loadingFinishedPreview.copy(fromAccountInformationErrorEvent = Event(result)))
            is Result.Success ->
                emit(loadingFinishedPreview.copy(fromAccountInformationSuccessEvent = Event(result.data)))
        }
    }

    fun getUpdatedPreviewFlowWithSignResult(
        fromAccountAddress: String,
        assetTransaction: AssetTransaction,
        preview: SenderAccountSelectionPreview
    ): Flow<SenderAccountSelectionPreview> = flow {
        emit(preview.copy(isLoading = true))
        val loadingFinishedPreview = preview.copy(isLoading = false)
        val isBalanceSufficient = amountTransactionValidationUseCase.isAmountBiggerThanBalance(
            address = fromAccountAddress,
            assetId = assetTransaction.assetId,
            amount = assetTransaction.amount
        )?.not()
        if (isBalanceSufficient == true) {
            emit(
                loadingFinishedPreview.copy(
                    signTransactionSuccessEvent = Event(Pair(fromAccountAddress, assetTransaction))
                )
            )
        } else {
            emit(
                loadingFinishedPreview.copy(
                    signTransactionErrorEvent = Event(Pair(R.string.error, R.string.this_account_doesn_t))
                )
            )
        }
    }

    private suspend fun getBaseNormalAccountListItems(): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase.createAccountSelectionListAccountItems(
            showHoldings = true,
            shouldIncludeWatchAccounts = false,
            showFailedAccounts = true
        )
    }

    private suspend fun getBaseNormalAccountListItemsFilteredByAssetId(
        assetId: Long
    ): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase.createAccountSelectionListAccountItemsFilteredByAssetId(
            assetId = assetId,
            showHoldings = true,
            shouldIncludeWatchAccounts = false,
            showFailedAccounts = true
        )
    }
}
