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

package com.algorand.android.modules.swap.transactionstatus.ui.mapper

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.RawRes
import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusPreview
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusType
import javax.inject.Inject

class SwapTransactionStatusPreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToSwapTransactionStatusPreview(
        swapTransactionStatusType: SwapTransactionStatusType,
        @RawRes
        transactionStatusAnimationResId: Int? = null,
        @DrawableRes
        transactionStatusAnimationBackgroundResId: Int,
        @ColorRes
        transactionStatusAnimationBackgroundTintResId: Int,
        @DrawableRes
        transactionStatusAnimationDrawableResId: Int? = null,
        @ColorRes
        transactionStatusAnimationDrawableTintResId: Int? = null,
        transactionStatusTitleAnnotatedString: AnnotatedString,
        transactionStatusDescriptionAnnotatedString: AnnotatedString,
        isTransactionDetailGroupVisible: Boolean,
        urlEncodedTransactionGroupId: String? = null,
        isPrimaryActionButtonVisible: Boolean,
        isGoToHomepageButtonVisible: Boolean,
        @StringRes
        primaryActionButtonTextResId: Int? = null,
        @StringRes
        secondaryActionButtonTextResId: Int? = null
    ): SwapTransactionStatusPreview {
        return SwapTransactionStatusPreview(
            swapTransactionStatusType = swapTransactionStatusType,
            transactionStatusAnimationResId = transactionStatusAnimationResId,
            transactionStatusAnimationBackgroundResId = transactionStatusAnimationBackgroundResId,
            transactionStatusAnimationBackgroundTintResId = transactionStatusAnimationBackgroundTintResId,
            transactionStatusAnimationDrawableResId = transactionStatusAnimationDrawableResId,
            transactionStatusAnimationDrawableTintResId = transactionStatusAnimationDrawableTintResId,
            transactionStatusTitleAnnotatedString = transactionStatusTitleAnnotatedString,
            transactionStatusDescriptionAnnotatedString = transactionStatusDescriptionAnnotatedString,
            isTransactionDetailGroupVisible = isTransactionDetailGroupVisible,
            urlEncodedTransactionGroupId = urlEncodedTransactionGroupId,
            isPrimaryActionButtonVisible = isPrimaryActionButtonVisible,
            isGoToHomepageButtonVisible = isGoToHomepageButtonVisible,
            primaryActionButtonTextResId = primaryActionButtonTextResId,
            secondaryActionButtonTextResId = secondaryActionButtonTextResId,
        )
    }
}
