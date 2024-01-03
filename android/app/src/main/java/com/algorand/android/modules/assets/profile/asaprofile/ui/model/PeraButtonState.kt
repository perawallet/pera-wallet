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

package com.algorand.android.modules.assets.profile.asaprofile.ui.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.R

enum class PeraButtonState(
    @ColorRes val backgroundColorResId: Int,
    @ColorRes val strokeColorResId: Int,
    @ColorRes val iconTintColorResId: Int,
    @ColorRes val textColor: Int,
    @DrawableRes val iconDrawableResId: Int
) {
    ADDITION(
        backgroundColorResId = R.color.primary_button_background_color,
        strokeColorResId = R.color.transparent,
        iconTintColorResId = R.color.primary_button_text_color,
        iconDrawableResId = R.drawable.ic_plus,
        textColor = R.color.primary_button_text_color
    ),
    REMOVAL(
        backgroundColorResId = R.color.background,
        strokeColorResId = R.color.button_stroke_color,
        iconTintColorResId = R.color.negative,
        iconDrawableResId = R.drawable.ic_trash,
        textColor = R.color.negative
    )
}
