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

package com.algorand.android.modules.swap.assetswap.ui.usecase

import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.currency.domain.usecase.DisplayedCurrencyUseCase
import com.algorand.android.modules.swap.assetswap.ui.mapper.AssetSwapPreviewMapper
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetAmountDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.utils.emptyString
import javax.inject.Inject

class AssetSwapInitialPreviewUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val selectedAssetDetailMapper: SelectedAssetDetailMapper,
    private val selectedAssetAmountDetailMapper: SelectedAssetAmountDetailMapper,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase,
    private val assetSwapPreviewMapper: AssetSwapPreviewMapper,
    private val displayedCurrencyUseCase: DisplayedCurrencyUseCase
) {

    fun getAssetSwapPreviewInitializationState(accountAddress: String, fromAssetId: Long): AssetSwapPreview {
        val ownedAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
            firstOrNull { fromAssetId == it.id } ?: first { it.isAlgo }
        }
        val selectedAssetDetail = selectedAssetDetailMapper.mapToSelectedAssetDetail(
            assetId = ownedAssetData.id,
            formattedBalance = ownedAssetData.formattedAmount,
            assetShortName = ownedAssetData.shortName,
            verificationTier = ownedAssetData.verificationTier,
            logoUrl = ownedAssetData.prismUrl,
            assetDecimal = ownedAssetData.decimals
        )
        val fromSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
            primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
        )
        val accountDetailSummary = accountDetailSummaryUseCase.getAccountDetailSummary(accountAddress)
        return assetSwapPreviewMapper.mapToAssetSwapPreview(
            accountDisplayName = accountDetailSummary.accountDisplayName,
            accountIconResource = accountDetailSummary.accountIconResource,
            fromSelectedAssetDetail = selectedAssetDetail,
            toSelectedAssetDetail = null,
            isSwapButtonEnabled = false,
            isLoadingVisible = false,
            fromSelectedAssetAmountDetail = fromSelectedAssetAmountDetail,
            toSelectedAssetAmountDetail = null,
            isSwitchAssetsButtonEnabled = false,
            isMaxAndPercentageButtonEnabled = false,
            errorEvent = null,
            swapQuote = null,
            clearToSelectedAssetDetailEvent = null,
            navigateToConfirmSwapFragmentEvent = null,
            formattedPercentageText = emptyString()
        )
    }
}
