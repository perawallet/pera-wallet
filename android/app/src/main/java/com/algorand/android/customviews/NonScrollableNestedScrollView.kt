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
import android.util.AttributeSet
import android.view.MotionEvent
import androidx.core.widget.NestedScrollView

class NonScrollableNestedScrollView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet?
) : NestedScrollView(context, attributeSet) {

    var isScrollEnable: Boolean = true

    override fun onInterceptTouchEvent(ev: MotionEvent?): Boolean {
        return if (isScrollEnable) super.onInterceptTouchEvent(ev) else false
    }

    override fun onTouchEvent(ev: MotionEvent?): Boolean {
        return if (isScrollEnable) super.onTouchEvent(ev) else false
    }
}
