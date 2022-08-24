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

package com.algorand.android.customviews.accountandassetitem

import android.content.Context
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import com.algorand.android.R
import com.algorand.android.databinding.ItemAccountAndAssetListBinding
import com.algorand.android.models.BaseItemConfiguration
import com.algorand.android.models.ButtonConfiguration
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseAccountAndAssetItemView<ITEM_CONFIG : BaseItemConfiguration> @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var dragButtonPressedListener: DragButtonPressedListener? = null

    private var checkButtonClickedListener: CheckButtonClickedListener? = null

    private var actionButtonClickListener: ActionButtonClickedListener? = null

    protected val binding = viewBinding(ItemAccountAndAssetListBinding::inflate)

    abstract fun initItemView(itemConfig: ITEM_CONFIG)

    init {
        initRootView()
    }

    protected open fun initPrimaryValue(primaryValue: String?) {
        val isPrimaryValueVisible = !primaryValue.isNullOrBlank()
        if (primaryValue.isNullOrBlank()) return
        binding.primaryValueTextView.apply {
            isVisible = isPrimaryValueVisible
            text = primaryValue
        }
    }

    protected open fun initSecondaryValue(secondaryValue: String?) {
        val isSecondaryValueVisible = !secondaryValue.isNullOrBlank()
        if (secondaryValue.isNullOrBlank()) return
        binding.secondaryValueTextView.apply {
            isVisible = isSecondaryValueVisible
            text = secondaryValue
        }
    }

    protected open fun initActionButton(actionButtonConfiguration: ButtonConfiguration?) {
        val isActionButtonVisible = actionButtonConfiguration != null
        if (actionButtonConfiguration == null) return
        binding.actionButton.apply {
            isVisible = isActionButtonVisible
            actionButtonConfiguration.iconDrawableResId?.run {
                icon = ContextCompat.getDrawable(context, this)
            }
            iconTint = actionButtonConfiguration.iconTintResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            backgroundTintList = actionButtonConfiguration.iconBackgroundColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            rippleColor = actionButtonConfiguration.iconRippleColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            setOnClickListener { actionButtonClickListener?.onClicked() }
        }
    }

    protected open fun initCheckButton(checkButtonConfiguration: ButtonConfiguration?) {
        val isCheckButtonVisible = checkButtonConfiguration != null
        if (checkButtonConfiguration == null) return
        binding.checkButton.apply {
            isVisible = isCheckButtonVisible
            checkButtonConfiguration.iconDrawableResId?.run {
                icon = ContextCompat.getDrawable(context, this)
            }
            iconTint = checkButtonConfiguration.iconTintResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            backgroundTintList = checkButtonConfiguration.iconBackgroundColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            rippleColor = checkButtonConfiguration.iconRippleColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            setOnClickListener { checkButtonClickedListener?.onClicked() }
        }
    }

    protected open fun initDragButton(dragButtonConfiguration: ButtonConfiguration?) {
        val isDragButtonVisible = dragButtonConfiguration != null
        if (dragButtonConfiguration == null) return
        binding.dragButton.apply {
            isVisible = isDragButtonVisible
            dragButtonConfiguration.iconDrawableResId?.run {
                icon = ContextCompat.getDrawable(context, this)
            }
            iconTint = dragButtonConfiguration.iconTintResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            backgroundTintList = dragButtonConfiguration.iconBackgroundColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            rippleColor = dragButtonConfiguration.iconRippleColorResId?.run {
                ColorStateList.valueOf(ContextCompat.getColor(context, this))
            }
            setOnTouchListener { _, event ->
                if (event.actionMasked == MotionEvent.ACTION_MOVE || event.actionMasked == MotionEvent.ACTION_DOWN) {
                    dragButtonPressedListener?.onPressed()
                }
                false
            }
        }
    }

    fun setDragButtonListener(listener: DragButtonPressedListener) {
        dragButtonPressedListener = listener
    }

    protected fun setCheckButtonListener(listener: CheckButtonClickedListener) {
        checkButtonClickedListener = listener
    }

    protected fun setActionButtonListener(listener: ActionButtonClickedListener) {
        actionButtonClickListener = listener
    }

    private fun initRootView() {
        val horizontalPadding = resources.getDimension(R.dimen.spacing_xlarge).toInt()
        updatePadding(left = horizontalPadding, right = horizontalPadding)
        minHeight = resources.getDimensionPixelSize(R.dimen.asset_item_view_min_height)
    }

    fun interface DragButtonPressedListener {
        fun onPressed()
    }

    fun interface CheckButtonClickedListener {
        fun onClicked()
    }

    fun interface ActionButtonClickedListener {
        fun onClicked()
    }
}
