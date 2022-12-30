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

import com.algorand.android.models.AssetDetail
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteAssetDetail
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAsTwoDecimals
import java.math.BigDecimal
import javax.inject.Inject

class AssetSwapPreviewAssetDetailUseCase @Inject constructor(
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val selectedAssetDetailMapper: SelectedAssetDetailMapper
) {

    fun createFromSelectedAssetDetail(
        fromAssetId: Long,
        accountAddress: String,
        previousState: AssetSwapPreview
    ): AssetSwapPreview.SelectedAssetDetail {
        val isFromAssetHasChanged = previousState.fromSelectedAssetDetail.assetId != fromAssetId
        return if (isFromAssetHasChanged) {
            val ownedAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
                firstOrNull { fromAssetId == it.id } ?: first { it.isAlgo }
            }
            createSelectedAssetDetail(ownedAssetData)
        } else {
            previousState.fromSelectedAssetDetail
        }
    }

    suspend fun createToSelectedAssetDetail(
        toAssetId: Long?,
        accountAddress: String,
        previousState: AssetSwapPreview
    ): AssetSwapPreview.SelectedAssetDetail? {
        val isToAssetHasChanged = previousState.toSelectedAssetDetail?.assetId != toAssetId
        if (toAssetId == null) return null
        return if (isToAssetHasChanged) {
            val ownedAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
                firstOrNull { toAssetId == it.id }
            }
            if (ownedAssetData == null) {
                val assetDetail = fetchAssetDetail(toAssetId)
                createSelectedAssetDetail(assetDetail ?: return null)
            } else {
                createSelectedAssetDetail(ownedAssetData)
            }
        } else {
            previousState.toSelectedAssetDetail
        }
    }

    fun createSelectedAssetDetailFromSwapQuoteAssetDetail(
        accountAddress: String,
        swapQuoteAssetDetail: SwapQuoteAssetDetail
    ): AssetSwapPreview.SelectedAssetDetail {
        val ownedAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, true).run {
            firstOrNull { swapQuoteAssetDetail.assetId == it.id }
        }
        return selectedAssetDetailMapper.mapToSelectedAssetDetail(
            assetId = swapQuoteAssetDetail.assetId,
            formattedBalance = ownedAssetData?.formattedAmount ?: BigDecimal.ZERO.formatAsTwoDecimals(),
            assetShortName = swapQuoteAssetDetail.shortName,
            verificationTier = swapQuoteAssetDetail.verificationTier,
            assetDecimal = ownedAssetData?.decimals ?: DEFAULT_ASSET_DECIMAL
        )
    }

    private fun createSelectedAssetDetail(ownedAssetData: OwnedAssetData): AssetSwapPreview.SelectedAssetDetail {
        return selectedAssetDetailMapper.mapToSelectedAssetDetail(
            assetId = ownedAssetData.id,
            formattedBalance = ownedAssetData.formattedAmount,
            assetShortName = ownedAssetData.shortName,
            verificationTier = ownedAssetData.verificationTier,
            assetDecimal = ownedAssetData.decimals
        )
    }

    private fun createSelectedAssetDetail(assetDetail: AssetDetail): AssetSwapPreview.SelectedAssetDetail {
        return selectedAssetDetailMapper.mapToSelectedAssetDetail(
            assetId = assetDetail.assetId,
            formattedBalance = BigDecimal.ZERO.formatAsTwoDecimals(),
            assetShortName = assetDetail.shortName,
            verificationTier = assetDetail.verificationTier,
            assetDecimal = assetDetail.fractionDecimals ?: DEFAULT_ASSET_DECIMAL
        )
    }

    private suspend fun fetchAssetDetail(toAssetId: Long): AssetDetail? {
        var assetDetail: AssetDetail? = null
        simpleAssetDetailUseCase.fetchAssetById(listOf(toAssetId)).collect {
            it.useSuspended(
                onSuccess = { assetDetailList ->
                    assetDetail = assetDetailList.firstOrNull { it.assetId == toAssetId }
                }
            )
        }
        return assetDetail
    }
}
