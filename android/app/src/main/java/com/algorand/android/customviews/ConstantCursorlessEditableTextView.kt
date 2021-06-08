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
import android.text.Editable
import android.text.Selection
import android.util.AttributeSet
import android.view.ActionMode
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.widget.AppCompatTextView

class ConstantCursorlessEditableTextView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatTextView(context, attrs) {

    init {
        initView()
    }

    override fun getDefaultEditable(): Boolean {
        return true
    }

    override fun isSuggestionsEnabled(): Boolean {
        return false
    }

    override fun isTextSelectable(): Boolean {
        return false
    }

    override fun onSelectionChanged(selStart: Int, selEnd: Int) {
        Selection.setSelection(text, text.length, text.length)
    }

    override fun getText(): Editable {
        return super.getText() as Editable
    }

    override fun setText(text: CharSequence, type: BufferType) {
        super.setText(text, BufferType.EDITABLE)
    }

    private fun initView() {
        isCursorVisible = false
        isLongClickable = false
        isEnabled = true
        isFocusable = true
        isFocusableInTouchMode = true
        includeFontPadding = false
        customSelectionActionModeCallback = object : ActionMode.Callback {
            override fun onActionItemClicked(mode: ActionMode?, item: MenuItem?): Boolean {
                return false
            }

            override fun onCreateActionMode(mode: ActionMode?, menu: Menu?): Boolean {
                return true
            }

            override fun onPrepareActionMode(mode: ActionMode?, menu: Menu?): Boolean {
                return false
            }

            override fun onDestroyActionMode(mode: ActionMode?) {
                // nothing to do
            }
        }
    }
}
