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
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatEditText

class PasteAwareEditText @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatEditText(context, attrs) {

    var listener: Listener? = null

    override fun onTextContextMenuItem(id: Int): Boolean {
        val result = super.onTextContextMenuItem(id)
        if (id == android.R.id.paste || id == android.R.id.pasteAsPlainText) {
           listener?.onPaste()
        }
        return result
    }

    fun doOnPaste(listener: Listener) {
        this.listener = listener
    }

    fun interface Listener {
        fun onPaste()
    }
}
