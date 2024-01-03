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

package com.algorand.android.ui.send.confirmation.ui.mapper

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.RawRes
import androidx.annotation.StringRes
import com.algorand.android.ui.send.confirmation.ui.model.TransactionStatusPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class TransactionStatusPreviewMapper @Inject constructor() {

    fun mapToTransactionStatusPreview(
        @RawRes transactionStatusAnimationResId: Int?,
        @DrawableRes transactionStatusAnimationBackgroundResId: Int,
        @ColorRes transactionStatusAnimationBackgroundTintResId: Int,
        @DrawableRes transactionStatusAnimationDrawableResId: Int?,
        @ColorRes transactionStatusAnimationDrawableTintResId: Int?,
        @StringRes transactionStatusTitleResId: Int,
        @StringRes transactionStatusDescriptionResId: Int,
        onExitSendAlgoNavigationEvent: Event<Unit>?
    ): TransactionStatusPreview {
        return TransactionStatusPreview(
            transactionStatusAnimationResId = transactionStatusAnimationResId,
            transactionStatusAnimationBackgroundResId = transactionStatusAnimationBackgroundResId,
            transactionStatusAnimationBackgroundTintResId = transactionStatusAnimationBackgroundTintResId,
            transactionStatusAnimationDrawableResId = transactionStatusAnimationDrawableResId,
            transactionStatusAnimationDrawableTintResId = transactionStatusAnimationDrawableTintResId,
            transactionStatusTitleResId = transactionStatusTitleResId,
            transactionStatusDescriptionResId = transactionStatusDescriptionResId,
            onExitSendAlgoNavigationEvent = onExitSendAlgoNavigationEvent
        )
    }
}
