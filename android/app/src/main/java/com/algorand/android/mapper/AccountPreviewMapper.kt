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

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.modules.accounts.domain.model.AccountPreview
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BasePortfolioValue
import javax.inject.Inject

class AccountPreviewMapper @Inject constructor(
    private val bottomGlobalErrorMapper: BottomGlobalErrorMapper
) {

    fun getEmptyAccountListState(isTestnetBadgeVisible: Boolean): AccountPreview {
        return AccountPreview(
            isEmptyStateVisible = true,
            isFullScreenAnimatedLoadingVisible = false,
            isBlockingLoadingVisible = false,
            isTestnetBadgeVisible = isTestnetBadgeVisible,
            shouldShowDialog = false,
            isMotionLayoutTransitionEnabled = false,
            portfolioValuesBackgroundRes = R.color.transparent,
            isPortfolioValueGroupVisible = false
        )
    }

    fun getFullScreenLoadingState(isTestnetBadgeVisible: Boolean): AccountPreview {
        return AccountPreview(
            isEmptyStateVisible = false,
            isFullScreenAnimatedLoadingVisible = true,
            isBlockingLoadingVisible = false,
            isTestnetBadgeVisible = isTestnetBadgeVisible,
            shouldShowDialog = false,
            isMotionLayoutTransitionEnabled = false,
            portfolioValuesBackgroundRes = R.color.transparent,
            isPortfolioValueGroupVisible = false
        )
    }

    fun getAlgoPriceInitialErrorState(
        accountListItems: List<BaseAccountListItem>,
        errorCode: Int?,
        isTestnetBadgeVisible: Boolean,
        portfolioValuesError: BasePortfolioValue.PortfolioValuesError
    ): AccountPreview {
        return AccountPreview(
            isEmptyStateVisible = false,
            isFullScreenAnimatedLoadingVisible = false,
            isBlockingLoadingVisible = false,
            accountListItems = accountListItems,
            bottomGlobalError = bottomGlobalErrorMapper.mapToBottomGlobalError(errorCode),
            isTestnetBadgeVisible = isTestnetBadgeVisible,
            portfolioValuesError = portfolioValuesError,
            shouldShowDialog = false,
            isMotionLayoutTransitionEnabled = true,
            portfolioValuesBackgroundRes = R.color.hero_bg,
            isPortfolioValueGroupVisible = true
        )
    }

    fun getSuccessAccountPreview(
        accountListItems: List<BaseAccountListItem>,
        isTestnetBadgeVisible: Boolean,
        shouldShowDialog: Boolean,
        portfolioValues: BasePortfolioValue.PortfolioValues?,
        portfolioValuesError: BasePortfolioValue.PortfolioValuesError?
    ): AccountPreview {
        return AccountPreview(
            isEmptyStateVisible = false,
            isFullScreenAnimatedLoadingVisible = false,
            isBlockingLoadingVisible = false,
            accountListItems = accountListItems,
            isTestnetBadgeVisible = isTestnetBadgeVisible,
            portfolioValues = portfolioValues,
            portfolioValuesError = portfolioValuesError,
            shouldShowDialog = shouldShowDialog,
            isMotionLayoutTransitionEnabled = true,
            portfolioValuesBackgroundRes = R.color.hero_bg,
            isPortfolioValueGroupVisible = true
        )
    }
}
