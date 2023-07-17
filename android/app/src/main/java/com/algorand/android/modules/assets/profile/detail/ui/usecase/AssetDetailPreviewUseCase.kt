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

package com.algorand.android.modules.assets.profile.detail.ui.usecase

import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.AssetTransaction
import com.algorand.android.modules.accountdetail.quickaction.AccountQuickActionsBottomSheetDirections
import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetAssetDetailUseCase
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetSelectedAssetExchangeValueUseCase
import com.algorand.android.modules.assets.profile.detail.ui.AssetDetailFragmentDirections
import com.algorand.android.modules.assets.profile.detail.ui.mapper.AssetDetailPreviewMapper
import com.algorand.android.modules.assets.profile.detail.ui.model.AssetDetailPreview
import com.algorand.android.modules.swap.reddot.domain.usecase.GetSwapFeatureRedDotVisibilityUseCase
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.ALGO_SHORT_NAME
import com.algorand.android.utils.AlgoAssetInformationProvider
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Event
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filterNotNull

@SuppressWarnings("LongParameterList")
class AssetDetailPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailPreviewMapper: AssetDetailPreviewMapper,
    private val getSwapFeatureRedDotVisibilityUseCase: GetSwapFeatureRedDotVisibilityUseCase,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper,
    private val getAssetDetailUseCase: GetAssetDetailUseCase,
    private val getSelectedAssetExchangeValueUseCase: GetSelectedAssetExchangeValueUseCase,
    private val algoAssetInformationProvider: AlgoAssetInformationProvider,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val accountStateHelperUseCase: AccountStateHelperUseCase,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase
) {

    fun updatePreviewForDiscoverMarketEvent(currentPreview: AssetDetailPreview): AssetDetailPreview {
        val safeTokenId = if (currentPreview.assetId == ALGO_ID) ALGO_SHORT_NAME else currentPreview.assetId.toString()
        return currentPreview.copy(
            navigateToDiscoverMarket = Event(
                TokenDetailInfo(tokenId = safeTokenId, poolId = null)
            )
        )
    }

    suspend fun updatePreviewWithSwapNavigation(
        assetId: Long,
        preview: AssetDetailPreview?,
        accountAddress: String
    ): AssetDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            var swapNavDirection: NavDirections? = null
            swapNavigationDestinationHelper.getSwapNavigationDestination(
                accountAddress = accountAddress,
                onNavToSwap = { address ->
                    swapNavDirection = AssetDetailFragmentDirections
                        .actionAssetDetailFragmentToSwapNavigation(address, assetId)
                },
                onNavToIntroduction = {
                    swapNavDirection = AssetDetailFragmentDirections
                        .actionAssetDetailFragmentToSwapIntroductionNavigation(accountAddress)
                }
            )
            val safeDirection = swapNavDirection ?: return preview
            preview?.copy(onNavigationEvent = Event(safeDirection))
        } else {
            preview?.copy(onShowGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithAssetAdditionNavigation(
        preview: AssetDetailPreview?,
        accountAddress: String
    ): AssetDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview?.copy(
                onNavigationEvent = Event(
                    AccountQuickActionsBottomSheetDirections
                        .actionAccountQuickActionsBottomSheetToAssetAdditionNavigation(accountAddress)
                )
            )
        } else {
            preview?.copy(onShowGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithOfframpNavigation(
        preview: AssetDetailPreview?,
        accountAddress: String
    ): AssetDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            preview?.copy(
                onNavigationEvent = Event(
                    AssetDetailFragmentDirections.actionAssetDetailFragmentToMoonpayNavigation(accountAddress)
                )
            )
        } else {
            preview?.copy(onShowGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    fun updatePreviewWithSendNavigation(
        preview: AssetDetailPreview?,
        accountAddress: String,
        assetId: Long
    ): AssetDetailPreview? {
        val hasAccountAuthority = accountStateHelperUseCase.hasAccountAuthority(accountAddress)
        return if (hasAccountAuthority) {
            val assetTransaction = AssetTransaction(senderAddress = accountAddress, assetId = assetId)
            preview?.copy(
                onNavigationEvent = Event(
                    AssetDetailFragmentDirections.actionAssetDetailFragmentToSendAlgoNavigation(assetTransaction)
                )
            )
        } else {
            preview?.copy(onShowGlobalErrorEvent = Event(R.string.this_action_is_not_available))
        }
    }

    suspend fun initAssetDetailPreview(
        accountAddress: String,
        assetId: Long,
        isQuickActionButtonsVisible: Boolean
    ): Flow<AssetDetailPreview?> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(accountAddress).filterNotNull(),
            getAssetDetailUseCase.getAssetDetail(assetId)
        ) { cachedAccountDetail, assetDetailResult ->
            val baseOwnedAssetDetail = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
                assetId = assetId,
                publicKey = accountAddress
            ) ?: return@combine null
            val isSwapButtonSelected = getRedDotVisibility(baseOwnedAssetDetail.isAlgo)
            val isUserOptedInToAsa = cachedAccountDetail.data?.accountInformation?.isAssetSupported(assetId) ?: false
            // TODO Check Error and Loading cases later
            val assetDetail = if (assetId != ALGO_ID) {
                (assetDetailResult as? DataResource.Success)?.data
            } else {
                algoAssetInformationProvider.getAlgoAssetInformation().data
            }
            val isAvailableOnDiscoverMobile = assetDetail?.isAvailableOnDiscoverMobile ?: false
            val formattedAssetPrice = getSelectedAssetExchangeValueUseCase.getSelectedAssetExchangeValue(assetDetail)
                ?.getFormattedValue(isCompact = true)
            val isMarketInformationVisible = isAvailableOnDiscoverMobile &&
                baseOwnedAssetDetail.verificationTier != VerificationTier.SUSPICIOUS &&
                assetDetail?.hasUsdValue() == true
            val isWatchAccount = cachedAccountDetail.data?.account?.type == Account.Type.WATCH
            val safeIsQuickActionButtonsVisible = isQuickActionButtonsVisible && !isWatchAccount
            assetDetailPreviewMapper.mapToAssetDetailPreview(
                baseOwnedAssetDetail = baseOwnedAssetDetail,
                accountDisplayName = getAccountDisplayNameUseCase.invoke(accountAddress),
                isQuickActionButtonsVisible = safeIsQuickActionButtonsVisible,
                isSwapButtonSelected = isSwapButtonSelected,
                isSwapButtonVisible = isUserOptedInToAsa && safeIsQuickActionButtonsVisible,
                isMarketInformationVisible = isMarketInformationVisible,
                last24HoursChange = assetDetail?.last24HoursAlgoPriceChangePercentage,
                formattedAssetPrice = formattedAssetPrice,
                accountDetailSummary = accountDetailSummaryUseCase.getAccountDetailSummary(cachedAccountDetail.data)
            )
        }.distinctUntilChanged()
    }

    private suspend fun getRedDotVisibility(isAlgo: Boolean): Boolean {
        return getSwapFeatureRedDotVisibilityUseCase.getSwapFeatureRedDotVisibility() && isAlgo
    }
}
