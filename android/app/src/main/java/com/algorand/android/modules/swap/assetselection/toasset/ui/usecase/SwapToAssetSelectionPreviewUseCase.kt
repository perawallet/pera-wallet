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

package com.algorand.android.modules.swap.assetselection.toasset.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.ScreenStateMapper
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.parity.domain.mapper.ParityValueMapper
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.swap.assetselection.base.ui.mapper.SwapAssetSelectionItemMapper
import com.algorand.android.modules.swap.assetselection.base.ui.mapper.SwapAssetSelectionPreviewMapper
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionItem
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionPreview
import com.algorand.android.modules.swap.assetselection.toasset.domain.GetAvailableTargetSwapAssetListUseCase
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAsset
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.utils.Event
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

class SwapToAssetSelectionPreviewUseCase @Inject constructor(
    private val getAvailableTargetSwapAssetListUseCase: GetAvailableTargetSwapAssetListUseCase,
    private val swapAssetSelectionPreviewMapper: SwapAssetSelectionPreviewMapper,
    private val swapAssetSelectionItemMapper: SwapAssetSelectionItemMapper,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val parityUseCase: ParityUseCase,
    private val parityValueMapper: ParityValueMapper,
    private val screenStateMapper: ScreenStateMapper
) {

    suspend fun getSwapAssetSelectionPreview(
        assetId: Long,
        accountAddress: String,
        query: String?
    ): Flow<SwapAssetSelectionPreview> = flow {
        getAvailableTargetSwapAssetListUseCase.getAvailableTargetSwapAssetList(assetId, query).map {
            it.useSuspended(
                onSuccess = { availableSwapAssetList ->
                    emit(createSuccessStatePreview(assetId, accountAddress, availableSwapAssetList))
                },
                onFailed = {
                    emit(createErrorStatePreview())
                },
                onLoading = {
                    val preview = swapAssetSelectionPreviewMapper.mapToSwapAssetSelectionPreview(
                        swapAssetSelectionItemList = emptyList(),
                        isLoading = true,
                        screenState = null,
                        navigateToAssetAdditionBottomSheetEvent = null,
                        assetSelectedEvent = null
                    )
                    emit(preview)
                }
            )
        }.collect()
    }

    fun updatePreviewWithAssetSelection(
        accountAddress: String,
        swapAssetSelectionItem: SwapAssetSelectionItem,
        previousState: SwapAssetSelectionPreview
    ): Flow<SwapAssetSelectionPreview> = flow {
        val accountAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, includeAlgo = true)
        val isAccountOptedInToSelectedAsset = accountAssetData.any { it.id == swapAssetSelectionItem.assetId }
        val newState = with(previousState) {
            if (isAccountOptedInToSelectedAsset) {
                copy(assetSelectedEvent = Event(swapAssetSelectionItem))
            } else {
                val assetAction = AssetAction(assetId = swapAssetSelectionItem.assetId, publicKey = accountAddress)
                copy(navigateToAssetAdditionBottomSheetEvent = Event(assetAction))
            }
        }
        emit(newState)
    }

    private fun createSwapAssetSelectionItemList(
        queriedAssetId: Long,
        accountAddress: String,
        availableAssetList: List<AvailableSwapAsset>
    ): List<SwapAssetSelectionItem> {
        val accountOwnedAssetList = accountAssetDataUseCase.getAccountOwnedAssetData(
            publicKey = accountAddress,
            includeAlgo = queriedAssetId != ALGO_ID
        )
        val (formattedZeroPrimaryValue, formattedZeroSecondaryValue) = getFormattedZeroPrimaryAndSecondaryValues()
        return availableAssetList.map { availableSwapAsset ->
            val accountOwnedAsset = accountOwnedAssetList.firstOrNull { it.id == availableSwapAsset.assetId }
            val (formattedPrimaryValue, formattedSecondaryValue) = getFormattedPrimaryAndSecondaryValuePair(
                accountOwnedAsset,
                formattedZeroPrimaryValue,
                formattedZeroSecondaryValue
            )
            swapAssetSelectionItemMapper.mapToSwapAssetSelectionItem(
                availableSwapAsset = availableSwapAsset,
                formattedPrimaryValue = formattedPrimaryValue,
                formattedSecondaryValue = formattedSecondaryValue,
                arePrimaryAndSecondaryValueVisible = accountOwnedAsset != null
            )
        }
    }

    private fun getFormattedPrimaryAndSecondaryValuePair(
        accountOwnedAsset: BaseAccountAssetData.BaseOwnedAssetData?,
        formattedZeroPrimaryValue: String,
        formattedZeroSecondaryValue: String,
    ): Pair<String, String> {
        val formattedPrimaryValue = accountOwnedAsset?.formattedCompactAmount ?: formattedZeroPrimaryValue
        val formattedSecondaryValue = accountOwnedAsset?.parityValueInSelectedCurrency?.getFormattedCompactValue()
            ?: formattedZeroSecondaryValue
        return formattedPrimaryValue to formattedSecondaryValue
    }

    private fun getFormattedZeroPrimaryAndSecondaryValues(): Pair<String, String> {
        val primarySelectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondarySelectedCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        val formattedZeroPrimaryValue = parityValueMapper
            .mapToParityValue(BigDecimal.ZERO, primarySelectedCurrencySymbol).getFormattedCompactValue()
        val formattedZeroSecondaryValue = parityValueMapper
            .mapToParityValue(BigDecimal.ZERO, secondarySelectedCurrencySymbol).getFormattedCompactValue()
        return formattedZeroPrimaryValue to formattedZeroSecondaryValue
    }

    private fun createSuccessStatePreview(
        assetId: Long,
        accountAddress: String,
        availableSwapAssetList: List<AvailableSwapAsset>
    ): SwapAssetSelectionPreview {
        val swapAssetSelectionItemList = createSwapAssetSelectionItemList(
            assetId,
            accountAddress,
            availableSwapAssetList
        )

        val screenState = if (swapAssetSelectionItemList.isEmpty()) {
            screenStateMapper.mapToCustomState(
                title = R.string.no_asset_found
            )
        } else {
            null
        }

        return swapAssetSelectionPreviewMapper.mapToSwapAssetSelectionPreview(
            swapAssetSelectionItemList = swapAssetSelectionItemList,
            isLoading = false,
            screenState = screenState,
            navigateToAssetAdditionBottomSheetEvent = null,
            assetSelectedEvent = null
        )
    }

    private fun createErrorStatePreview(): SwapAssetSelectionPreview {
        return swapAssetSelectionPreviewMapper.mapToSwapAssetSelectionPreview(
            swapAssetSelectionItemList = emptyList(),
            isLoading = false,
            screenState = screenStateMapper.mapToCustomState(
                title = R.string.something_went_wrong,
                description = R.string.we_can_not_show_assets
            ),
            navigateToAssetAdditionBottomSheetEvent = null,
            assetSelectedEvent = null
        )
    }
}
