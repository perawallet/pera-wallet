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

package com.algorand.android.assetsearch.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.R
import com.algorand.android.assetsearch.domain.model.VerificationTier

enum class VerificationTierConfiguration(
    @DrawableRes val drawableResId: Int?,
    @ColorRes val textColorResId: Int
) {
    VERIFIED(
        drawableResId = R.drawable.ic_asa_verified,
        textColorResId = R.color.text_main
    ) {
        override fun toVerificationTier(): VerificationTier = VerificationTier.VERIFIED
    },
    UNVERIFIED(
        drawableResId = null,
        textColorResId = R.color.text_main
    ) {
        override fun toVerificationTier(): VerificationTier = VerificationTier.UNVERIFIED
    },
    TRUSTED(
        drawableResId = R.drawable.ic_asa_trusted,
        textColorResId = R.color.text_main
    ) {
        override fun toVerificationTier(): VerificationTier = VerificationTier.TRUSTED
    },
    SUSPICIOUS(
        drawableResId = R.drawable.ic_asa_danger,
        textColorResId = R.color.negative
    ) {
        override fun toVerificationTier(): VerificationTier = VerificationTier.SUSPICIOUS
    };

    abstract fun toVerificationTier(): VerificationTier
}
