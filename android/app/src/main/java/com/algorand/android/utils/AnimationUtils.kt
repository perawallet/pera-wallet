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

import android.animation.ObjectAnimator
import android.view.View
import android.view.animation.Animation
import android.view.animation.LinearInterpolator

private const val FULL_ANGLE = 360f

fun View.rotateContinuously(clockWise: Boolean, duration: Long) {
    val rotationAnimation = if (clockWise) {
        ObjectAnimator.ofFloat(this, "rotation", 0f, FULL_ANGLE)
    } else {
        ObjectAnimator.ofFloat(this, "rotation", FULL_ANGLE, 0f)
    }
    rotationAnimation.apply {
        this.repeatCount = Animation.INFINITE
        this.duration = duration
        this.interpolator = LinearInterpolator()
    }.start()
}
