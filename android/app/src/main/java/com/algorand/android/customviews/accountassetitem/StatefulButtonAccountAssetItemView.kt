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

package com.algorand.android.customviews.accountassetitem

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.view.MotionEvent
import android.widget.ProgressBar
import androidx.annotation.ColorRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.setTextAndVisibility
import com.algorand.android.utils.extensions.show
import com.google.android.material.button.MaterialButton

class StatefulButtonAccountAssetItemView(
    context: Context,
    attrs: AttributeSet?
) : BaseAccountAndAssetItemView(context, attrs) {

    private val actionButton: MaterialButton
        get() = binding.actionButton

    private val actionTextButton: MaterialButton
        get() = binding.actionTextButton

    private val progressBar: ProgressBar
        get() = binding.progressBar

    fun setButtonState(state: AccountAssetItemButtonState) {
        when (state) {
            AccountAssetItemButtonState.PROGRESS -> {
                actionButton.hide()
                progressBar.show()
            }
            AccountAssetItemButtonState.UNDO_REKEY -> {
                actionButton.hide()
                actionButton.hide()
                actionTextButton.setTextAndVisibility(state.actionButtonTextResId)
            }
            AccountAssetItemButtonState.ADDITION,
            AccountAssetItemButtonState.REMOVAL,
            AccountAssetItemButtonState.CONFIRMATION,
            AccountAssetItemButtonState.DRAGGABLE,
            AccountAssetItemButtonState.CHECKED,
            AccountAssetItemButtonState.UNCHECKED,
            AccountAssetItemButtonState.COPY,
            AccountAssetItemButtonState.WARNING -> {
                progressBar.hide()
                setButtonBackgroundColor(state.backgroundColorResId)
                setButtonStroke(state.strokeColorResId)
                setButtonIcon(state.iconTintColorResId, state.iconDrawableResId)
                setActionButtonSize(state.actionButtonSizeDimenResId, state.actionButtonIconSizeDimenResId)
                setButtonEnable(state.isEnabled)
                actionButton.show()
            }
        }
        updateStatefulButtonsFlowPaddingIfNeeded()
    }

    fun setActionButtonClickListener(onClick: (() -> Unit)?) {
        actionButton.setOnClickListener { onClick?.invoke() }
    }

    fun setActionButtonOnLongClickListener(onLongClick: () -> Unit) {
        actionButton.setOnLongClickListener { onLongClick(); true }
    }

    @SuppressLint("ClickableViewAccessibility")
    fun setActionButtonOnTouchClickListener(onTouch: () -> Unit) {
        actionButton.setOnTouchListener { _, event ->
            if (event.actionMasked == MotionEvent.ACTION_MOVE || event.actionMasked == MotionEvent.ACTION_DOWN) {
                onTouch.invoke()
            }
            false
        }
    }

    fun setActionTextButtonClickListener(onClick: (() -> Unit)?) {
        actionTextButton.setOnClickListener { onClick?.invoke() }
    }

    private fun setButtonEnable(isEnable: Boolean) {
        actionButton.isEnabled = isEnable
    }

    private fun setButtonIcon(iconTintColorResId: Int?, iconDrawableResId: Int?) {
        actionButton.apply {
            icon = AppCompatResources.getDrawable(context, iconDrawableResId ?: return@apply)
            iconTint = ColorStateList.valueOf(getColorOrTransparent(iconTintColorResId))
        }
    }

    private fun setButtonStroke(strokeColorResId: Int?) {
        val color = getColorOrTransparent(strokeColorResId)
        actionButton.strokeColor = ColorStateList.valueOf(color)
        if (strokeColorResId != null) {
            actionButton.setStrokeWidthResource(R.dimen.button_stroke_width)
        }
    }

    private fun setButtonBackgroundColor(backgroundColorResId: Int?) {
        val color = getColorOrTransparent(backgroundColorResId)
        actionButton.setBackgroundColor(color)
    }

    private fun setActionButtonSize(iconSizeDimenRes: Int?, actionButtonIconSizeDimenResId: Int?) {
        actionButton.run {
            val buttonSize = resources.getDimensionPixelOffset(iconSizeDimenRes ?: return)
            val iconSize = resources.getDimensionPixelOffset(actionButtonIconSizeDimenResId ?: return)
            updateLayoutParams<LayoutParams> {
                width = buttonSize
                height = buttonSize
            }
            this.iconSize = iconSize
        }
    }

    private fun getColorOrTransparent(@ColorRes colorResId: Int?): Int {
        val safeColorId = colorResId ?: R.color.transparent
        return ContextCompat.getColor(context, safeColorId)
    }
}
