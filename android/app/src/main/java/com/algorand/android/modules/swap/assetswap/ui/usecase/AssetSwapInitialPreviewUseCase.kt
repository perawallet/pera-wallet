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

import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.currency.domain.usecase.DisplayedCurrencyUseCase
import com.algorand.android.modules.swap.assetswap.ui.mapper.AssetSwapPreviewMapper
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetAmountDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.CheckUserHasAssetBalanceUseCase
import com.algorand.android.utils.emptyString
import javax.inject.Inject

class AssetSwapInitialPreviewUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val selectedAssetDetailMapper: SelectedAssetDetailMapper,
    private val selectedAssetAmountDetailMapper: SelectedAssetAmountDetailMapper,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase,
    private val assetSwapPreviewMapper: AssetSwapPreviewMapper,
    private val checkUserHasAssetBalanceUseCase: CheckUserHasAssetBalanceUseCase,
    private val displayedCurrencyUseCase: DisplayedCurrencyUseCase
) {

    fun getAssetSwapPreviewInitializationState(
        accountAddress: String,
        fromAssetId: Long,
        toAssetId: Long?
    ): AssetSwapPreview {
        val fromAssetDetail = getFromAssetDetail(accountAddress, fromAssetId)
        val toAssetDetail = getToAssetDetail(accountAddress, toAssetId)

        val fromSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
            primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
        )
        val toSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
            primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
        )
        val accountDetailSummary = accountDetailSummaryUseCase.getAccountDetailSummary(accountAddress)
        // TODO update isSwitchAssetsButtonEnabled when we merge tinyman-swap-2
        return assetSwapPreviewMapper.mapToAssetSwapPreview(
            accountDisplayName = accountDetailSummary.accountDisplayName,
            accountIconResource = accountDetailSummary.accountIconResource,
            fromSelectedAssetDetail = fromAssetDetail,
            toSelectedAssetDetail = toAssetDetail,
            isSwapButtonEnabled = false,
            isLoadingVisible = false,
            fromSelectedAssetAmountDetail = fromSelectedAssetAmountDetail,
            toSelectedAssetAmountDetail = toSelectedAssetAmountDetail,
            isSwitchAssetsButtonEnabled = if (toAssetId == null) {
                false
            } else {
                checkUserHasAssetBalanceUseCase.hasUserAssetBalance(accountAddress, toAssetId)
            },
            isMaxAndPercentageButtonEnabled = toAssetDetail != null,
            errorEvent = null,
            swapQuote = null,
            clearToSelectedAssetDetailEvent = null,
            navigateToConfirmSwapFragmentEvent = null,
            formattedPercentageText = emptyString()
        )
    }

    private fun getFromAssetDetail(accountAddress: String, assetId: Long): AssetSwapPreview.SelectedAssetDetail {
        val ownedFromAssetDetail = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
            firstOrNull { assetId == it.id } ?: first { it.isAlgo }
        }
        return getAssetDetail(ownedFromAssetDetail)
    }

    private fun getToAssetDetail(accountAddress: String, assetId: Long?): AssetSwapPreview.SelectedAssetDetail? {
        val ownedToAssetDetail = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
            firstOrNull { assetId == it.id } ?: return null
        }
        return getAssetDetail(ownedToAssetDetail)
    }

    private fun getAssetDetail(ownedAssetData: OwnedAssetData): AssetSwapPreview.SelectedAssetDetail {
        return selectedAssetDetailMapper.mapToSelectedAssetDetail(
            assetId = ownedAssetData.id,
            formattedBalance = ownedAssetData.formattedAmount,
            assetShortName = ownedAssetData.shortName,
            verificationTier = ownedAssetData.verificationTier,
            assetDecimal = ownedAssetData.decimals
        )
    }
}
