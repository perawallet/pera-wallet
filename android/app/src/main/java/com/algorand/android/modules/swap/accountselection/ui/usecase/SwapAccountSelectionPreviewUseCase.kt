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

package com.algorand.android.modules.swap.accountselection.ui.usecase

import com.algorand.android.modules.swap.accountselection.ui.mapper.SwapAccountSelectionPreviewMapper
import com.algorand.android.modules.swap.accountselection.ui.model.SwapAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class SwapAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val swapAccountSelectionPreviewMapper: SwapAccountSelectionPreviewMapper
) {

    fun getSwapAccountSelectionInitialPreview(): SwapAccountSelectionPreview {
        return swapAccountSelectionPreviewMapper.mapToSwapAccountSelectionPreview(
            accountListItems = emptyList(),
            isLoading = true,
            navToSwapNavigationEvent = null,
            errorEvent = null,
            isEmptyStateVisible = false
        )
    }

    suspend fun getSwapAccountSelectionPreview(): SwapAccountSelectionPreview {
        val accountSelectionList = accountSelectionListUseCase.createAccountSelectionListAccountItems(
            showHoldings = false,
            shouldIncludeWatchAccounts = false,
            showFailedAccounts = true
        )
        return swapAccountSelectionPreviewMapper.mapToSwapAccountSelectionPreview(
            accountListItems = accountSelectionList,
            isLoading = false,
            navToSwapNavigationEvent = null,
            errorEvent = null,
            isEmptyStateVisible = accountSelectionList.isEmpty()
        )
    }

    fun getAccountSelectedUpdatedPreview(
        accountAddress: String,
        previousState: SwapAccountSelectionPreview
    ): SwapAccountSelectionPreview {
        return previousState.copy(navToSwapNavigationEvent = Event(accountAddress))
    }
}
