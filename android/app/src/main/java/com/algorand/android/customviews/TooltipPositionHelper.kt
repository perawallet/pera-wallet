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

import android.graphics.Point
import android.graphics.Rect
import kotlin.math.absoluteValue

internal object TooltipPositionHelper {

    fun getPopupDialogPositionPoint(
        anchorRect: Rect,
        offset: Int,
        screenWidth: Int,
        contentWidth: Int,
        contentHeight: Int
    ): Point {
        val positionX = getSafePositionX(anchorRect, offset, screenWidth, contentWidth)
        val positionY = anchorRect.top - contentHeight
        return Point(positionX, positionY)
    }

    fun getArrowTranslationX(
        anchorRect: Rect,
        tooltipPositionX: Int,
        contentWidth: Int,
        arrowWidth: Int,
        cornerRadius: Int
    ): Float {
        val anchorViewCenterX = anchorRect.centerX()
        val leftLimit = tooltipPositionX + cornerRadius
        val rightLimit = tooltipPositionX + contentWidth - cornerRadius - arrowWidth
        val rawPositionX = anchorViewCenterX - (arrowWidth / 2)
        return (rawPositionX.coerceIn(leftLimit, rightLimit).toFloat() - tooltipPositionX).absoluteValue
    }

    private fun getSafePositionX(anchorRect: Rect, offset: Int, screenWidth: Int, contentWidth: Int): Int {
        val maxPositionX = screenWidth - offset

        // Left side of the rect
        val rawPositionX = anchorRect.centerX() - (contentWidth / 2)
        // Right side of the rect
        val rawPositionX2 = rawPositionX + contentWidth

        return when {
            rawPositionX <= offset -> offset
            rawPositionX2 >= maxPositionX -> rawPositionX - (rawPositionX2 - maxPositionX)
            else -> rawPositionX
        }
    }
}
