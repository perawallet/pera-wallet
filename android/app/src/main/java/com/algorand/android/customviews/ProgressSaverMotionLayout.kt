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
import android.os.Parcelable
import android.util.AttributeSet
import androidx.constraintlayout.motion.widget.MotionLayout
import com.algorand.android.models.MotionLayoutProgressSavedState

class ProgressSaverMotionLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : MotionLayout(context, attrs) {

    override fun onSaveInstanceState(): Parcelable {
        return MotionLayoutProgressSavedState(super.onSaveInstanceState(), targetPosition)
    }

    override fun onRestoreInstanceState(state: Parcelable?) {
        super.onRestoreInstanceState(state)
        (state as? MotionLayoutProgressSavedState)?.let {
            progress = it.progress
        }
    }
}
