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

package com.algorand.android.modules.swap.assetswap.ui.model

import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.formatAmount

data class AssetSwapPreview(
    val accountDisplayName: AccountDisplayName,
    val accountIconResource: AccountIconResource?,
    val fromSelectedAssetDetail: SelectedAssetDetail,
    val toSelectedAssetDetail: SelectedAssetDetail?,
    val isSwapButtonEnabled: Boolean,
    val isLoadingVisible: Boolean,
    val fromSelectedAssetAmountDetail: SelectedAssetAmountDetail?,
    val toSelectedAssetAmountDetail: SelectedAssetAmountDetail?,
    val isSwitchAssetsButtonEnabled: Boolean,
    val isMaxAndPercentageButtonEnabled: Boolean,
    val formattedPercentageText: String,
    val errorEvent: Event<ErrorResource>?,
    val swapQuote: SwapQuote?,
    val clearToSelectedAssetDetailEvent: Event<Unit>?,
    val navigateToConfirmSwapFragmentEvent: Event<SwapQuote>?
) {

    data class SelectedAssetDetail(
        val assetId: Long,
        val formattedBalance: String,
        val assetShortName: AssetName,
        val verificationTierConfiguration: VerificationTierConfiguration,
        val assetDrawableProvider: BaseAssetDrawableProvider,
        val assetDecimal: Int
    )

    data class SelectedAssetAmountDetail(
        val amount: String?,
        val formattedApproximateValue: String,
        val assetDecimal: Int
    ) {

        val formattedAmount: String?
            get() = amount?.toBigDecimalOrNull()?.formatAmount(assetDecimal, false)
    }
}
