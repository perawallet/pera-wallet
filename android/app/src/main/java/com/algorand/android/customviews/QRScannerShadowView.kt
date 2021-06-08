/*
 * Copyright 2019 Algorand, Inc.
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
import android.graphics.Canvas
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View
import androidx.core.content.ContextCompat
import com.algorand.android.R

class QRScannerShadowView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : View(context, attrs) {

    private val overlaySize by lazy {
        resources.getDimensionPixelSize(R.dimen.qr_code_overlay_size)
    }

    override fun dispatchDraw(canvas: Canvas?) {
        super.dispatchDraw(canvas)

        val leftRightOutsideOverlayWidth: Float = ((width - overlaySize) / 2).toFloat()
        val topBottomOutsideOverlayHeight: Float = ((height - overlaySize) / 2).toFloat()
        val overLayBottomY: Float = topBottomOutsideOverlayHeight + overlaySize
        val overlayEndX: Float = leftRightOutsideOverlayWidth + overlaySize

        val shadowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = ContextCompat.getColor(context, R.color.qr_code_outside_rectangle_transparency)
        }

        canvas?.drawRect(
            0f,
            0f,
            leftRightOutsideOverlayWidth,
            height.toFloat(),
            shadowPaint
        )
        canvas?.drawRect(
            overlayEndX,
            0f,
            width.toFloat(),
            height.toFloat(),
            shadowPaint
        )

        canvas?.drawRect(
            leftRightOutsideOverlayWidth,
            0f,
            overlayEndX,
            topBottomOutsideOverlayHeight,
            shadowPaint
        )

        canvas?.drawRect(
            leftRightOutsideOverlayWidth,
            overLayBottomY,
            overlayEndX,
            height.toFloat(),
            shadowPaint
        )
    }
}
