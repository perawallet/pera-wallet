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

import android.os.Handler
import android.text.Selection
import android.text.Spannable
import android.text.method.LinkMovementMethod
import android.view.MotionEvent
import android.widget.TextView

class LongClickLinkMovementMethod : LinkMovementMethod() {

    private var longClickHandler: Handler? = null
    private var isLongPressed = false

    override fun onTouchEvent(widget: TextView, buffer: Spannable, event: MotionEvent): Boolean {
        when (event.action) {
            MotionEvent.ACTION_CANCEL -> onActionCancel()
            MotionEvent.ACTION_UP, MotionEvent.ACTION_DOWN -> {
                var x = event.x.toInt()
                var y = event.y.toInt()
                x -= widget.totalPaddingLeft
                y -= widget.totalPaddingTop
                x += widget.scrollX
                y += widget.scrollY
                val line = widget.layout.getLineForVertical(y)
                val off = widget.layout.getOffsetForHorizontal(line, x.toFloat())
                val link = buffer.getSpans(off, off, LongClickableSpan::class.java)
                if (link.isNotEmpty()) {
                    if (event.action == MotionEvent.ACTION_UP) {
                        onActionUp(link.first(), widget)
                    } else {
                        onActionDown(link.first(), widget, buffer)
                    }
                    return true
                }
            }
        }
        return super.onTouchEvent(widget, buffer, event)
    }

    private fun onActionCancel() {
        longClickHandler?.removeCallbacksAndMessages(null)
    }

    private fun onActionUp(span: LongClickableSpan, widget: TextView) {
        longClickHandler?.removeCallbacksAndMessages(null)
        if (!isLongPressed) {
            span.onClick(widget)
        }
        isLongPressed = false
    }

    private fun onActionDown(span: LongClickableSpan, widget: TextView, buffer: Spannable) {
        Selection.setSelection(buffer, buffer.getSpanStart(span), buffer.getSpanEnd(span))
        longClickHandler?.postDelayed({
            span.onLongClick(widget)
            isLongPressed = true
        }, LONG_CLICK_TIME)
    }

    companion object {
        private const val LONG_CLICK_TIME = 1000L
        private var instance: LongClickLinkMovementMethod? = null

        fun getInstance(): LongClickLinkMovementMethod? {
            if (instance == null) {
                instance = LongClickLinkMovementMethod()
                instance?.longClickHandler = Handler()
            }
            return instance
        }
    }
}
