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

package com.algorand.android.models.ui

import androidx.annotation.ColorRes
import androidx.annotation.DimenRes
import androidx.annotation.DrawableRes
import com.algorand.android.R

enum class AccountAssetItemButtonState(
    @ColorRes val backgroundColorResId: Int?,
    @ColorRes val strokeColorResId: Int?,
    @ColorRes val iconTintColorResId: Int?,
    @DrawableRes val iconDrawableResId: Int?,
    @DimenRes val actionButtonSizeDimenResId: Int?,
    @DimenRes val actionButtonIconSizeDimenResId: Int?,
    val isEnabled: Boolean
) {
    PROGRESS(
        backgroundColorResId = R.color.layer_gray_lighter,
        strokeColorResId = R.color.transparent,
        iconTintColorResId = null,
        iconDrawableResId = null,
        actionButtonSizeDimenResId = null,
        actionButtonIconSizeDimenResId = null,
        isEnabled = false
    ),
    ADDITION(
        backgroundColorResId = R.color.background,
        strokeColorResId = R.color.button_stroke_color,
        iconTintColorResId = R.color.text_gray,
        iconDrawableResId = R.drawable.ic_plus,
        actionButtonSizeDimenResId = R.dimen.action_button_large,
        actionButtonIconSizeDimenResId = R.dimen.action_button_small,
        isEnabled = true
    ),
    REMOVAL(
        backgroundColorResId = R.color.background,
        strokeColorResId = R.color.button_stroke_color,
        iconTintColorResId = R.color.negative,
        iconDrawableResId = R.drawable.ic_trash,
        actionButtonSizeDimenResId = R.dimen.action_button_large,
        actionButtonIconSizeDimenResId = R.dimen.action_button_small,
        isEnabled = true
    ),
    CONFIRMATION(
        backgroundColorResId = R.color.layer_gray_lighter,
        strokeColorResId = null,
        iconTintColorResId = R.color.text_gray,
        iconDrawableResId = R.drawable.ic_check,
        actionButtonSizeDimenResId = R.dimen.action_button_large,
        actionButtonIconSizeDimenResId = R.dimen.action_button_small,
        isEnabled = false
    ),
    DRAGGABLE(
        backgroundColorResId = R.color.transparent,
        strokeColorResId = R.color.transparent,
        iconTintColorResId = R.color.text_gray_lighter,
        iconDrawableResId = R.drawable.ic_drag_drop,
        actionButtonSizeDimenResId = R.dimen.action_button_xlarge,
        actionButtonIconSizeDimenResId = R.dimen.action_button_large,
        isEnabled = true
    ),
    CHECKED(
        backgroundColorResId = R.color.success,
        strokeColorResId = R.color.success,
        iconTintColorResId = R.color.success_checkmark,
        iconDrawableResId = R.drawable.ic_check,
        actionButtonSizeDimenResId = R.dimen.action_button_normal,
        actionButtonIconSizeDimenResId = R.dimen.action_button_small,
        isEnabled = true
    ),
    UNCHECKED(
        backgroundColorResId = R.color.transparent,
        strokeColorResId = R.color.layer_gray,
        iconTintColorResId = null,
        iconDrawableResId = null,
        actionButtonSizeDimenResId = R.dimen.action_button_normal,
        actionButtonIconSizeDimenResId = R.dimen.action_button_small,
        isEnabled = true
    )
}
