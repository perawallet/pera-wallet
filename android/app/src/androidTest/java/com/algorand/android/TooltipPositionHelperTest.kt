@file:SuppressWarnings("MagicNumber")
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

package com.algorand.android

import android.graphics.Rect
import com.algorand.android.customviews.TooltipPositionHelper
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4

@RunWith(JUnit4::class)
class TooltipPositionHelperTest {

    companion object {
        private const val OFFSET = 63
        private const val SCREEN_WIDTH = 1080
        private const val CONTENT_HEIGHT = 100
        private const val ANCHOR_VIEW_SIZE = 64
    }

    /**
     * Given
     *  |  |          |  |
     *  | x|xxxxxxxx  |  |
     *  |  |          |  |
     *
     *
     * Expected
     *  |  |          |  |
     *  |  |xxxxxxxxx |  |
     *  |  |          |  |
     */
    @Test
    fun checkIfMinOffsetWorks() {
        val anchorRect = createAnchorViewRect(OFFSET)
        val contentWidth = 400
        val point = TooltipPositionHelper
            .getPopupDialogPositionPoint(anchorRect, OFFSET, SCREEN_WIDTH, contentWidth, CONTENT_HEIGHT)
        val isShiftedToTheRight = point.x >= getRawPositionX(anchorRect, contentWidth) && point.x == OFFSET
        assert(isShiftedToTheRight)
    }

    /**
     * Given
     *  |  |          |  |
     *  |  |  xxxxxxxx|x |
     *  |  |          |  |
     *
     *
     * Expected
     *  |  |          |  |
     *  |  | xxxxxxxxx|  |
     *  |  |          |  |
     */
    @Test
    fun checkIfMaxOffsetWorks() {
        val anchorRect = createAnchorViewRect(954)
        val contentWidth = 596
        val point = TooltipPositionHelper
            .getPopupDialogPositionPoint(anchorRect, OFFSET, SCREEN_WIDTH, contentWidth, CONTENT_HEIGHT)
        val isShiftedToTheLeft =
            point.x <= getRawPositionX(anchorRect, contentWidth) && point.x + contentWidth == SCREEN_WIDTH - OFFSET
        assert(isShiftedToTheLeft)
    }

    /**
     * Given
     *  |  |          |  |
     *  |  |    xxxx  |  |
     *  |  |          |  |
     *
     *
     * Expected
     *  |  |          |  |
     *  |  |    xxxx  |  |
     *  |  |          |  |
     */

    @Test
    fun checkIfNoShiftingWorks() {
        val anchorRect = createAnchorViewRect(500)
        val contentWidth = 300
        val point = TooltipPositionHelper
            .getPopupDialogPositionPoint(anchorRect, OFFSET, SCREEN_WIDTH, contentWidth, CONTENT_HEIGHT)
        val isStayedInTheSamePosition = point.x == getRawPositionX(anchorRect, contentWidth)
        assert(isStayedInTheSamePosition)
    }

    /**
     * Given
     *  |  |          |  |
     *  |  |xxxxxxxxxx|  |
     *  |  |          |  |
     *
     *
     * Expected
     *  |  |          |  |
     *  |  |xxxxxxxxxx|  |
     *  |  |          |  |
     */
    @Test
    fun checkIfMaxWidthWorks() {
        val anchorRect = createAnchorViewRect(OFFSET)
        val contentWidth = SCREEN_WIDTH - OFFSET * 2
        val point = TooltipPositionHelper
            .getPopupDialogPositionPoint(anchorRect, OFFSET, SCREEN_WIDTH, contentWidth, CONTENT_HEIGHT)
        val isStayedInTheSamePosition = point.x == OFFSET
        assert(isStayedInTheSamePosition)
    }

    private fun getRawPositionX(anchorRect: Rect, contentWidth: Int): Int {
        return anchorRect.centerX() - (contentWidth / 2)
    }

    private fun createAnchorViewRect(positionX: Int): Rect {
        val randomPositionY = positionX + 25
        return Rect(
            positionX,
            randomPositionY,
            positionX + ANCHOR_VIEW_SIZE,
            randomPositionY + ANCHOR_VIEW_SIZE
        )
    }
}
