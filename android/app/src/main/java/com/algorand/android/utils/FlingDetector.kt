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

package com.algorand.android.utils

import android.view.GestureDetector
import android.view.MotionEvent
import kotlin.math.abs

class FlingDetector(val listener: FlingDetectorListener) : GestureDetector.SimpleOnGestureListener() {

    /**
     * Whether or not you use GestureDetector.OnGestureListener, it's best practice to implement an onDown()
     * method that returns true. This is because all gestures begin with an onDown() message.
     * If you return false from onDown(), as GestureDetector.SimpleOnGestureListener does by default,
     * the system assumes that you want to ignore the rest of the gesture, and
     * the other methods of GestureDetector.OnGestureListener never get called.
     * This has the potential to cause unexpected problems in your app. The only time you should
     * return false from onDown() is if you truly want to ignore an entire gesture.
     */
    override fun onDown(e: MotionEvent?): Boolean = true

    override fun onFling(event1: MotionEvent?, event2: MotionEvent?, velocityX: Float, velocityY: Float): Boolean {
        if (event2 == null || event1 == null) return false
        var result = false
        val diffY = event2.y - event1.y
        val diffX = event2.x - event1.x
        if (abs(diffX) > abs(diffY)) {
            if (abs(diffX) > SWIPE_THRESHOLD && abs(velocityX) > SWIPE_VELOCITY_THRESHOLD) {
                result = if (diffX > 0) listener.onSwipeRight() else listener.onSwipeLeft()
            }
        } else if (abs(diffY) > SWIPE_THRESHOLD && abs(velocityY) > SWIPE_VELOCITY_THRESHOLD) {
            result = if (diffY > 0) listener.onSwipeDown() else listener.onSwipeUp()
        }
        return result
    }

    interface FlingDetectorListener {
        fun onSwipeUp(): Boolean = false
        fun onSwipeLeft(): Boolean = false
        fun onSwipeRight(): Boolean = false
        fun onSwipeDown(): Boolean = false
    }

    companion object {
        private const val SWIPE_THRESHOLD = 100
        private const val SWIPE_VELOCITY_THRESHOLD = 100
    }
}
