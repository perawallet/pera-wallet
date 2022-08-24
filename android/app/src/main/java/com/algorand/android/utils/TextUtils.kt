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

import android.graphics.Paint
import android.graphics.Rect

fun calculateTextSizeInBounds(text: String, containerWidth: Int, initialTextSize: Float, minTextSize: Float): Float {
    val paint = Paint()
    val bounds = Rect()
    var textSize = initialTextSize
    paint.textSize = textSize
    paint.getTextBounds(text, 0, text.length, bounds)
    while (bounds.width() > containerWidth && textSize >= minTextSize) {
        textSize--
        paint.textSize = textSize
        paint.getTextBounds(text, 0, text.length, bounds)
    }
    return textSize
}
