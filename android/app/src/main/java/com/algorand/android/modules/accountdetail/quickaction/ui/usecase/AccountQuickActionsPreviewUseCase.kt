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

package com.algorand.android.modules.accountdetail.quickaction.ui.usecase

import androidx.navigation.NavDirections
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.models.AssetTransaction
import com.algorand.android.modules.accountdetail.quickaction.AccountQuickActionsBottomSheetDirections
import com.algorand.android.modules.accountdetail.quickaction.ui.mapper.AccountQuickActionsPreviewMapper
import com.algorand.android.modules.accountdetail.quickaction.ui.model.AccountQuickActionsPreview
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.utils.Event
import javax.inject.Inject

class AccountQuickActionsPreviewUseCase @Inject constructor(
    private val accountQuickActionsPreviewMapper: AccountQuickActionsPreviewMapper,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun getInitialPreview(): AccountQuickActionsPreview {
        return accountQuickActionsPreviewMapper.mapToAccountQuickActionsPreview()
    }

    suspend fun updatePreviewWithSwapNavigation(
        preview: AccountQuickActionsPreview,
        accountAddress: String
    ): AccountQuickActionsPreview {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
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
            val safeDirection = swapNavDirection ?: return preview
            preview.copy(onNavigationEvent = Event(safeDirection))
        } else {
            preview.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithAssetAdditionNavigation(
        preview: AccountQuickActionsPreview,
        accountAddress: String
    ): AccountQuickActionsPreview {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview.copy(
                onNavigationEvent = Event(
                    AccountQuickActionsBottomSheetDirections
                        .actionAccountQuickActionsBottomSheetToAssetAdditionNavigation(accountAddress)
                )
            )
        } else {
            preview.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithOfframpNavigation(
        preview: AccountQuickActionsPreview,
        accountAddress: String
    ): AccountQuickActionsPreview {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview.copy(
                onNavigationEvent = Event(
                    AccountQuickActionsBottomSheetDirections
                        .actionAccountQuickActionsBottomSheetToBuySellActionsBottomSheet(accountAddress)
                )
            )
        } else {
            preview.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithSendNavigation(
        preview: AccountQuickActionsPreview,
        accountAddress: String
    ): AccountQuickActionsPreview {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            val assetTransaction = AssetTransaction(senderAddress = accountAddress)
            preview.copy(
                onNavigationEvent = Event(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
            )
        } else {
            preview.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }
}
