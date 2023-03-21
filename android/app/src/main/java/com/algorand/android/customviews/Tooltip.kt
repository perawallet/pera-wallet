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

package com.algorand.android.customviews

import android.content.Context
import android.graphics.Point
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.util.AttributeSet
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.PopupWindow
import androidx.core.content.ContextCompat
import androidx.core.view.doOnLayout
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.algorand.android.R
import com.algorand.android.databinding.CustomTooltipBinding
import com.algorand.android.models.TooltipConfig
import com.algorand.android.utils.getDisplaySize
import com.algorand.android.utils.viewbinding.viewBinding

// TODO currently doesn't support RTL.
class Tooltip(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private val popupWindow: PopupWindow

    private lateinit var positionPoint: Point

    private var contentWidth: Int = 0
    private var contentHeight: Int = 0

    private val screenWidth: Int
    private val screenHeight: Int

    private val binding = viewBinding(CustomTooltipBinding::inflate)

    init {
        val displaySize = context.getDisplaySize()
        screenWidth = displaySize.x
        screenHeight = displaySize.y
        popupWindow = PopupWindow(context).apply {
            isClippingEnabled = true
            isOutsideTouchable = true
            contentView = binding.root
            setBackgroundDrawable(ColorDrawable(ContextCompat.getColor(context, R.color.transparent)))
        }
    }

    fun show(tooltipConfig: TooltipConfig, lifecycleOwner: LifecycleOwner?) {
        with(tooltipConfig) {
            binding.tooltipTextView.setText(tooltipTextResId)

            measureContentSize(offsetX)
            val anchorRect = getAnchorViewRect(anchor)
            setPositions(anchorRect, offsetX)
            showPopupWindow(anchor, anchorRect, offsetX)
            initTooltipArrow(anchorRect)

            if (lifecycleOwner != null) enableAutoDismiss(lifecycleOwner.lifecycle)
        }
    }

    private fun setPositions(anchorRect: Rect, offsetX: Int) {
        positionPoint = TooltipPositionHelper
            .getPopupDialogPositionPoint(anchorRect, offsetX, screenWidth, contentWidth, contentHeight)
    }

    private fun showPopupWindow(anchorView: View, anchorRect: Rect, offsetX: Int) {
        popupWindow.apply {
            width = contentWidth
            height = contentHeight
            showAtLocation(anchorView, Gravity.NO_GRAVITY, positionPoint.x, positionPoint.y)
        }
    }

    private fun measureContentSize(offsetX: Int) {
        val widthMeasureSpec = MeasureSpec.makeMeasureSpec(screenWidth - (offsetX * 2), MeasureSpec.AT_MOST)
        val heightMeasureSpec = MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        binding.root.measure(widthMeasureSpec, heightMeasureSpec)
        contentWidth = binding.root.measuredWidth
        contentHeight = binding.root.measuredHeight
    }

    private fun getAnchorViewRect(anchorView: View): Rect {
        // Get location of anchor view on screen
        val screenPos = IntArray(2)
        anchorView.getLocationOnScreen(screenPos)

        val anchorViewPositionX = screenPos[POSITION_X_INDEX]
        val anchorViewPositionY = screenPos[POSITION_Y_INDEX]
        // Get rect for anchor view
        return Rect(
            anchorViewPositionX,
            anchorViewPositionY,
            anchorViewPositionX + anchorView.width,
            anchorViewPositionY + anchorView.height
        )
    }

    private fun initTooltipArrow(anchorRect: Rect) {
        val backgroundCornerRadius = resources.getDimensionPixelSize(R.dimen.tooltip_background_corner_radius)
        binding.tooltipImageView.doOnLayout {
            it.x = TooltipPositionHelper.getArrowTranslationX(
                anchorRect,
                positionPoint.x,
                contentWidth,
                it.measuredWidth,
                backgroundCornerRadius
            )
        }
    }

    private fun enableAutoDismiss(lifecycle: Lifecycle) {
        lifecycle.addObserver(object : LifecycleEventObserver {
            override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
                if (event == Lifecycle.Event.ON_PAUSE) {
                    popupWindow.dismiss()
                    source.lifecycle.removeObserver(this)
                }
            }
        })
        postDelayed({ popupWindow.dismiss() }, AUTO_DISMISS_DELAY)
    }

    companion object {
        const val POSITION_X_INDEX = 0
        const val POSITION_Y_INDEX = 1
        private const val AUTO_DISMISS_DELAY = 5_000L
    }
}
