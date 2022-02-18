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

package com.algorand.android.models

import android.view.View
import androidx.core.content.ContextCompat
import com.google.android.material.button.MaterialButton

abstract class BaseToolbarButton {

    abstract val layoutResId: Int
    abstract val backgroundTintResId: Int?
    abstract val onClick: () -> Unit
    abstract fun initAttributes(button: View)

    protected fun setBackgroundTint(button: MaterialButton) {
        backgroundTintResId?.let { tintResId ->
            if (tintResId == -1) return
            with(button) {
                backgroundTintList = ContextCompat.getColorStateList(context, tintResId)
            }
        }
    }
}
