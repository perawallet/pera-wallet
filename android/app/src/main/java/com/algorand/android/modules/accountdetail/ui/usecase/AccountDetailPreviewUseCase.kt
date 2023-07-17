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
import com.algorand.android.R
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.modules.accountdetail.ui.AccountDetailFragmentDirections
import com.algorand.android.modules.accountdetail.ui.mapper.AccountDetailPreviewMapper
import com.algorand.android.modules.accountdetail.ui.model.AccountDetailPreview
import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.mapNotNull

class AccountDetailPreviewUseCase @Inject constructor(
    private val accountDetailPreviewMapper: AccountDetailPreviewMapper,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountStateHelperUseCase: AccountStateHelperUseCase,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase
) {

    fun getInitialPreview(): AccountDetailPreview {
        return accountDetailPreviewMapper.mapToAccountDetail()
    }

    fun getAssetLongClickUpdatedPreview(
        previousState: AccountDetailPreview,
        assetId: Long
    ): AccountDetailPreview {
        return with(previousState) {
            if (assetId != AssetInformation.ALGO_ID) {
                copy(copyAssetIDToClipboardEvent = Event(assetId))
            } else {
                previousState
            }
        }
    }

    fun getAccountSummaryFlow(publicKey: String): Flow<AccountDetailSummary> {
        return accountDetailUseCase.getAccountDetailCacheFlow(publicKey).mapNotNull {
            accountDetailSummaryUseCase.getAccountDetailSummary(it?.data)
        }
    }

    suspend fun updatePreviewWithSwapNavigation(
        preview: AccountDetailPreview?,
        accountAddress: String
    ): AccountDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
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
            val safeDirection = swapNavDirection ?: return preview
            preview?.copy(onNavigationEvent = Event(safeDirection))
        } else {
            preview?.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithAssetAdditionNavigation(
        preview: AccountDetailPreview?,
        accountAddress: String
    ): AccountDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview?.copy(
                onNavigationEvent = Event(
                    AccountDetailFragmentDirections.actionAccountDetailFragmentToAssetAdditionNavigation(
                        accountAddress
                    )
                )
            )
        } else {
            preview?.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithOfframpNavigation(
        preview: AccountDetailPreview?,
        accountAddress: String
    ): AccountDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview?.copy(
                onNavigationEvent = Event(
                    AccountDetailFragmentDirections.actionAccountDetailFragmentToBuySellActionsBottomSheet(
                        accountAddress
                    )
                )
            )
        } else {
            preview?.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithSendNavigation(preview: AccountDetailPreview?, accountAddress: String): AccountDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            val assetTransaction = AssetTransaction(senderAddress = accountAddress)
            preview?.copy(
                onNavigationEvent = Event(
                    AccountDetailFragmentDirections.actionGlobalSendAlgoNavigation(assetTransaction)
                )
            )
        } else {
            preview?.copy(showGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }
}
