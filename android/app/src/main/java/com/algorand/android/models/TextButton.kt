/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import android.view.View
import androidx.annotation.StringRes
import com.algorand.android.R
import com.google.android.material.button.MaterialButton

data class TextButton(
    @StringRes private val stringResId: Int,
    override val backgroundTintResId: Int? = null,
    override val onClick: () -> Unit
) : BaseToolbarButton() {

    override val layoutResId: Int
        get() = R.layout.custom_text_tab_button

    override fun initAttributes(button: View) {
        (button as? MaterialButton)?.setText(stringResId)
    }
}
