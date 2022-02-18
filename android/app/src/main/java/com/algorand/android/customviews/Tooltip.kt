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
import android.graphics.Rect
import android.graphics.drawable.ColorDrawable
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.PopupWindow
import androidx.annotation.StringRes
import androidx.core.content.ContextCompat
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import com.algorand.android.R
import com.algorand.android.databinding.CustomTooltipBinding
import com.algorand.android.utils.getDisplaySize

// TODO currently doesn't support RTL.
class Tooltip(private val context: Context) {

    private val popupWindow: PopupWindow

    private var positionX: Int = 0
    private var positionY: Int = 0

    private var contentWidth: Int = 0
    private var contentHeight: Int = 0

    private var screenWidth: Int = 0
    private var screenHeight: Int = 0

    private var binding: CustomTooltipBinding

    init {
        val displaySize = context.getDisplaySize()
        screenWidth = displaySize.x
        screenHeight = displaySize.y
        binding = CustomTooltipBinding.inflate(LayoutInflater.from(context))
        popupWindow = PopupWindow(context).apply {
            isClippingEnabled = true
            isOutsideTouchable = true
            contentView = binding.root
            setBackgroundDrawable(ColorDrawable(ContextCompat.getColor(context, R.color.transparent)))
        }
    }

    fun show(config: Config, lifecycleOwner: LifecycleOwner? = null) {
        with(config) {
            binding.tooltipTextView.setText(tooltipTextResId)

            // Get location of anchor view on screen
            val screenPos = IntArray(2)
            anchor.getLocationOnScreen(screenPos)
            // Get rect for anchor view
            val anchorRect =
                Rect(screenPos[0], screenPos[1], screenPos[0] + anchor.width, screenPos[1] + anchor.height)

            measureContentSize(offsetX)

            setPositionX(offsetX, anchorToLeft)
            setPositionY(anchorRect)

            initTooltipArrow(anchorRect, offsetX, anchorToLeft)

            popupWindow.apply {
                width = contentWidth
                height = contentHeight
                showAtLocation(anchor, Gravity.NO_GRAVITY, positionX, positionY)
            }

            if (lifecycleOwner != null) {
                enableAutoDismiss(lifecycleOwner.lifecycle)
            }
        }
    }

    private fun measureContentSize(offsetX: Int) {
        val widthMeasureSpec = View.MeasureSpec.makeMeasureSpec(
            screenWidth - (offsetX * 2),
            View.MeasureSpec.AT_MOST
        )
        val heightMeasureSpec = View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
        binding.root.measure(widthMeasureSpec, heightMeasureSpec)
        contentWidth = binding.root.measuredWidth
        contentHeight = binding.root.measuredHeight
    }

    private fun setPositionX(offsetX: Int, anchorToLeft: Boolean) {
        positionX = if (anchorToLeft) {
            offsetX
        } else {
            screenWidth - contentWidth - offsetX
        }
    }

    private fun setPositionY(anchor: Rect) {
        positionY = anchor.bottom
    }

    private fun initTooltipArrow(anchorRect: Rect, offsetX: Int, anchorToLeft: Boolean) {
        val offset = if (anchorToLeft) {
            anchorRect.centerX() - offsetX - (binding.tooltipImageView.measuredWidth / 2)
        } else {
            screenWidth - anchorRect.centerX() - (binding.tooltipImageView.measuredWidth / 2) - offsetX
        }

        (binding.tooltipImageView.layoutParams as FrameLayout.LayoutParams).apply {
            if (anchorToLeft) {
                gravity = Gravity.START
                marginStart = offset
            } else {
                gravity = Gravity.END
                marginEnd = offset
            }
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
    }

    data class Config(
        val anchor: View,
        val offsetX: Int = 0,
        @StringRes val tooltipTextResId: Int,
        val anchorToLeft: Boolean
    )
}
