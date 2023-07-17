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

package com.algorand.android.modules.accounts.domain.model

import androidx.annotation.ColorRes
import androidx.navigation.NavDirections
import com.algorand.android.models.BottomGlobalError
import com.algorand.android.utils.Event

data class AccountPreview(
    val isEmptyStateVisible: Boolean,
    val isFullScreenAnimatedLoadingVisible: Boolean,
    val isBlockingLoadingVisible: Boolean,
    val accountListItems: List<BaseAccountListItem> = emptyList(),
    val portfolioValueItem: BasePortfolioValueItem? = null,
    val bottomGlobalError: BottomGlobalError? = null,
    val isTestnetBadgeVisible: Boolean,
    val isMotionLayoutTransitionEnabled: Boolean,
    @ColorRes val portfolioValuesBackgroundRes: Int,
    val isSuccessStateVisible: Boolean,
    val hasNewNotification: Boolean,
    val onGiftCardsTutorialDisplayEvent: Event<Int>? = null,
    val onAccountAddressCopyTutorialDisplayEvent: Event<Int>? = null,
    val onSwapTutorialDisplayEvent: Event<Int>? = null,
    val swapNavigationDestinationEvent: Event<NavDirections>? = null,
    val giftCardsNavigationDestinationEvent: Event<NavDirections>? = null,
    val notificationPermissionEvent: Event<Unit>? = null
)
