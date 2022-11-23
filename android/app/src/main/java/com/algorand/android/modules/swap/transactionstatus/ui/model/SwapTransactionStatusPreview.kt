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

package com.algorand.android.modules.swap.transactionstatus.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.RawRes
import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.Event

data class SwapTransactionStatusPreview(
    val swapTransactionStatusType: SwapTransactionStatusType,

    @RawRes
    val transactionStatusAnimationResId: Int?,
    @DrawableRes
    val transactionStatusAnimationBackgroundResId: Int,
    @ColorRes
    val transactionStatusAnimationBackgroundTintResId: Int,
    @DrawableRes
    val transactionStatusAnimationDrawableResId: Int?,
    @ColorRes
    val transactionStatusAnimationDrawableTintResId: Int?,

    val transactionStatusTitleAnnotatedString: AnnotatedString,
    val transactionStatusDescriptionAnnotatedString: AnnotatedString,

    val isTransactionDetailGroupVisible: Boolean,
    val urlEncodedTransactionGroupId: String?,

    val isPrimaryActionButtonVisible: Boolean,
    val isGoToHomepageButtonVisible: Boolean,
    @StringRes
    val primaryActionButtonTextResId: Int?,
    @StringRes
    val secondaryActionButtonTextResId: Int?,
    val navigateBackEvent: Event<Unit>? = null,
    val navigateToAssetSwapFragmentEvent: Event<Unit>? = null
)
