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

import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.mapper.AssetActionMapper
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.accountselection.ui.SwapAccountSelectionFragmentDirections
import com.algorand.android.modules.swap.accountselection.ui.mapper.SwapAccountSelectionPreviewMapper
import com.algorand.android.modules.swap.accountselection.ui.model.SwapAccountSelectionPreview
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AccountSelectionListUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest

class SwapAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val swapAccountSelectionPreviewMapper: SwapAccountSelectionPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetActionMapper: AssetActionMapper
) {

    fun getSwapAccountSelectionInitialPreview(): SwapAccountSelectionPreview {
        return swapAccountSelectionPreviewMapper.mapToSwapAccountSelectionPreview(
            accountListItems = emptyList(),
            isLoading = true,
            navToSwapNavigationEvent = null,
            errorEvent = null,
            isEmptyStateVisible = false,
            optInToAssetEvent = null
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
            isEmptyStateVisible = accountSelectionList.isEmpty(),
            optInToAssetEvent = null
        )
    }

    fun getAccountSelectedUpdatedPreview(
        accountAddress: String,
        fromAssetId: Long?,
        toAssetId: Long?,
        defaultFromAssetIdArg: Long,
        defaultToAssetIdArg: Long,
        previousState: SwapAccountSelectionPreview
    ): SwapAccountSelectionPreview {
        with(previousState) {
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data?.accountInformation
                ?: return copy(errorEvent = Event(AnnotatedString(R.string.an_error_occured)))

            if (fromAssetId != null) {
                val isUserOptedIntoFromAsset = accountDetail.isAssetSupported(fromAssetId)
                if (!isUserOptedIntoFromAsset) {
                    return copy(errorEvent = Event(AnnotatedString(R.string.an_error_occured)))
                }

                if (toAssetId != null) {
                    val isUserOptedIntoToAsset = accountDetail.isAssetSupported(toAssetId)
                    if (!isUserOptedIntoToAsset) {
                        return getAssetAdditionPreview(previousState, toAssetId, accountAddress)
                    }
                }
            }

            if (toAssetId != null) {
                val isUserOptedIntoToAsset = accountDetail.isAssetSupported(toAssetId)
                if (!isUserOptedIntoToAsset) {
                    return getAssetAdditionPreview(previousState, toAssetId, accountAddress)
                }
            }

            return copy(
                navToSwapNavigationEvent = getSwapNavigationDestinationEvent(
                    accountAddress = accountAddress,
                    fromAssetId = fromAssetId ?: defaultFromAssetIdArg,
                    toAssetId = toAssetId ?: defaultToAssetIdArg
                )
            )
        }
    }

    private fun getAssetAdditionPreview(
        previousState: SwapAccountSelectionPreview,
        assetId: Long,
        accountAddress: String
    ): SwapAccountSelectionPreview {
        val assetAdditionAction = assetActionMapper.mapTo(
            assetId = assetId,
            publicKey = accountAddress,
            asset = null
        )
        return previousState.copy(
            isLoading = true,
            optInToAssetEvent = Event(assetAdditionAction)
        )
    }

    suspend fun getAssetAddedPreview(
        accountAddress: String,
        fromAssetId: Long,
        toAssetId: Long,
        previousState: SwapAccountSelectionPreview,
        scope: CoroutineScope
    ) = channelFlow<SwapAccountSelectionPreview> {
        accountDetailUseCase.fetchAndCacheAccountDetail(accountAddress, scope).collectLatest {
            it.useSuspended(
                onSuccess = {
                    val swapNavigationEvent = getSwapNavigationDestinationEvent(accountAddress, fromAssetId, toAssetId)
                    send(previousState.copy(navToSwapNavigationEvent = swapNavigationEvent))
                },
                onFailed = {
                    // TODO We may consider showing exception message instead of default one
                    send(previousState.copy(errorEvent = Event(AnnotatedString(R.string.an_error_occured))))
                }
            )
        }
    }

    private fun getSwapNavigationDestinationEvent(
        accountAddress: String,
        fromAssetId: Long,
        toAssetId: Long
    ): Event<NavDirections> {
        return Event(
            SwapAccountSelectionFragmentDirections.actionSwapAccountSelectionFragmentToSwapNavigation(
                accountAddress = accountAddress,
                fromAssetId = fromAssetId,
                toAssetId = toAssetId
            )
        )
    }
}
