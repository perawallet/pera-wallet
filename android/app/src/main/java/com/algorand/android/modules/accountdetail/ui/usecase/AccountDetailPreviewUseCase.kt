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
import com.algorand.android.modules.accountdetail.ui.AccountDetailFragmentDirections
import com.algorand.android.modules.accountdetail.ui.mapper.AccountDetailPreviewMapper
import com.algorand.android.modules.accountdetail.ui.model.AccountDetailPreview
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.utils.Event
import javax.inject.Inject

class AccountDetailPreviewUseCase @Inject constructor(
    private val accountDetailPreviewMapper: AccountDetailPreviewMapper,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper
) {

    fun getInitialPreview(): AccountDetailPreview {
        return accountDetailPreviewMapper.mapToAccountDetail(
            swapNavigationDirectionEvent = null
        )
    }

    suspend fun getSwapNavigationUpdatedPreview(
        accountAddress: String,
        previousState: AccountDetailPreview
    ): AccountDetailPreview {
        var swapNavDirection: NavDirections? = null
        swapNavigationDestinationHelper.getSwapNavigationDestination(
            accountAddress = accountAddress,
            onNavToIntroduction = {
                swapNavDirection = AccountDetailFragmentDirections
                    .actionAccountDetailFragmentToSwapIntroductionNavigation(accountAddress)
            },
            onNavToSwap = { address ->
                swapNavDirection = AccountDetailFragmentDirections
                    .actionAccountDetailFragmentToSwapNavigation(address)
            }
        )
        return swapNavDirection?.let { direction ->
            previousState.copy(swapNavigationDirectionEvent = Event(direction))
        } ?: previousState
    }
}
