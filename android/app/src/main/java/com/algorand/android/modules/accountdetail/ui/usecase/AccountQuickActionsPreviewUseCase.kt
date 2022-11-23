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

package com.algorand.android.modules.accountdetail.ui.usecase

import androidx.navigation.NavDirections
import com.algorand.android.modules.accountdetail.ui.AccountQuickActionsBottomSheetDirections
import com.algorand.android.modules.accountdetail.ui.mapper.AccountQuickActionsPreviewMapper
import com.algorand.android.modules.accountdetail.ui.model.AccountQuickActionsPreview
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class AccountQuickActionsPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountQuickActionsPreviewMapper: AccountQuickActionsPreviewMapper,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper
) {

    fun getInitialPreview(accountAddress: String): AccountQuickActionsPreview {
        return accountQuickActionsPreviewMapper.mapToAccountQuickActionsPreview(
            isSwapButtonVisible = accountDetailUseCase.canAccountSignTransaction(accountAddress),
            swapNavigationDirectionEvent = null
        )
    }

    suspend fun getSwapNavigationUpdatedPreview(
        accountAddress: String,
        previousState: AccountQuickActionsPreview
    ): AccountQuickActionsPreview {
        var swapNavDirection: NavDirections? = null
        swapNavigationDestinationHelper.getSwapNavigationDestination(
            accountAddress = accountAddress,
            onNavToSwap = { address ->
                swapNavDirection = AccountQuickActionsBottomSheetDirections
                    .actionAccountQuickActionsBottomSheetToSwapNavigation(address)
            },
            onNavToIntroduction = {
                swapNavDirection = AccountQuickActionsBottomSheetDirections
                    .actionAccountQuickActionsBottomSheetToSwapIntroductionNavigation()
            }
        )

        return swapNavDirection?.let { direction ->
            previousState.copy(swapNavigationDirectionEvent = Event(direction))
        } ?: previousState
    }
}
