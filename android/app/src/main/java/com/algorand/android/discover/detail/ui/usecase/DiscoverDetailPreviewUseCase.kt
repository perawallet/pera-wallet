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

package com.algorand.android.discover.detail.ui.usecase

import android.content.SharedPreferences
import androidx.navigation.NavDirections
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.detail.domain.model.DetailActionRequest
import com.algorand.android.discover.detail.ui.DiscoverDetailFragmentDirections
import com.algorand.android.discover.detail.ui.mapper.BuySellActionRequestMapper
import com.algorand.android.discover.detail.ui.model.BuySellActionRequest
import com.algorand.android.discover.detail.ui.model.DiscoverDetailAction
import com.algorand.android.discover.detail.ui.model.DiscoverDetailPreview
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForResponse
import com.algorand.android.modules.swap.utils.DiscoverSwapNavigationDestinationHelper
import com.algorand.android.modules.tracking.discover.detail.DiscoverDetailEventTracker
import com.algorand.android.utils.Event
import com.algorand.android.utils.fromJson
import com.algorand.android.utils.preference.getSavedThemePreference
import com.google.gson.Gson
import javax.inject.Inject

class DiscoverDetailPreviewUseCase @Inject constructor(
    private val buySellActionRequestMapper: BuySellActionRequestMapper,
    private val sharedPreferences: SharedPreferences,
    private val discoverSwapNavigationDestinationHelper: DiscoverSwapNavigationDestinationHelper,
    private val discoverDetailEventTracker: DiscoverDetailEventTracker,
    private val gson: Gson
) {

    fun getInitialStatePreview(tokenDetail: TokenDetailInfo) = DiscoverDetailPreview(
        themePreference = sharedPreferences.getSavedThemePreference(),
        isLoading = true,
        reloadPageEvent = Event(Unit),
        tokenDetail = tokenDetail
    )

    fun onPageRequestedShouldOverrideUrlLoading(
        previousState: DiscoverDetailPreview,
        url: String
    ) = previousState.copy(
        externalPageRequestedEvent = Event(url)
    )

    fun onPageFinished(previousState: DiscoverDetailPreview) = previousState.copy(
        isLoading = false
    )

    fun onError(previousState: DiscoverDetailPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onHttpError(previousState: DiscoverDetailPreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )

    suspend fun logTokenDetailActionButtonClick(data: String) {
        val detailActionRequest = getDetailActionRequestFromJson(data)

        detailActionRequest?.let {
            logDetailAction(
                detailActionRequest = it,
                assetIn = getSafeAssetIdForResponse(it.assetIn?.toLongOrNull()) ?: -1,
                assetOut = getSafeAssetIdForResponse(it.assetOut?.toLongOrNull()) ?: -1
            )
        }
    }

    suspend fun handleTokenDetailActionButtonClick(
        data: String,
        previousState: DiscoverDetailPreview
    ): DiscoverDetailPreview {
        val detailActionRequest = getDetailActionRequestFromJson(data)

        val buySellActionRequest = buySellActionRequestMapper.mapToBuySellActionRequest(
            assetInId = getSafeAssetIdForResponse(detailActionRequest?.assetIn?.toLongOrNull()) ?: -1,
            assetOutId = getSafeAssetIdForResponse(detailActionRequest?.assetOut?.toLongOrNull()) ?: -1,
            detailAction = detailActionRequest?.action
        )
        var swapNavDirection: NavDirections? = null
        when (buySellActionRequest.destination) {
            BuySellActionRequest.Destination.MOONPAY -> {
                swapNavDirection = DiscoverDetailFragmentDirections.actionDiscoverDetailFragmentToMoonpayNavigation()
            }
            BuySellActionRequest.Destination.SWAP -> {
                discoverSwapNavigationDestinationHelper.getSwapNavigationDestination(
                    onNavToIntroduction = {
                        swapNavDirection = DiscoverDetailFragmentDirections
                            .actionDiscoverDetailFragmentToSwapIntroductionNavigation(
                                fromAssetId = buySellActionRequest.assetInId ?: -1L,
                                toAssetId = buySellActionRequest.assetOutId ?: -1L
                            )
                    },
                    onNavToAccountSelection = {
                        swapNavDirection = DiscoverDetailFragmentDirections
                            .actionDiscoverDetailFragmentToSwapAccountSelectionNavigation(
                                fromAssetId = buySellActionRequest.assetInId ?: -1L,
                                toAssetId = buySellActionRequest.assetOutId ?: -1L
                            )
                    }
                )
            }
            BuySellActionRequest.Destination.ONRAMP -> {}
            else -> {}
        }
        return swapNavDirection?.let { direction ->
            previousState.copy(buySellActionEvent = Event(direction))
        } ?: previousState
    }

    private fun getDetailActionRequestFromJson(data: String): DetailActionRequest? {
        return gson.fromJson<DetailActionRequest>(data)
    }

    private suspend fun logDetailAction(
        detailActionRequest: DetailActionRequest,
        assetIn: Long,
        assetOut: Long
    ) {
        when (detailActionRequest.action) {
            DiscoverDetailAction.BUY_ALGO, DiscoverDetailAction.SWAP_TO_TOKEN -> {
                discoverDetailEventTracker.logTokenDetailBuyEvent(
                    assetIn = assetIn,
                    assetOut = assetOut
                )
            }
            DiscoverDetailAction.SWAP_FROM_ALGO, DiscoverDetailAction.SWAP_FROM_TOKEN -> {
                discoverDetailEventTracker.logTokenDetailSellEvent(
                    assetIn = assetIn,
                    assetOut = assetOut
                )
            }
            DiscoverDetailAction.UNKNOWN, null -> {
                // No log action defined here
            }
        }
    }
}
