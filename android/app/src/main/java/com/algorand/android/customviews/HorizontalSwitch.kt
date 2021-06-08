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
import android.view.View
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.ViewCompat
import androidx.customview.widget.ViewDragHelper
import com.algorand.android.R
import com.algorand.android.databinding.CustomHorizontalSwitchBinding
import com.algorand.android.utils.setXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.math.max
import kotlin.math.min

class HorizontalSwitch @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var isLeftSelected: Boolean = true
    private var listener: Listener? = null

    private val binding = viewBinding(CustomHorizontalSwitchBinding::inflate)

    init {
        initView(attrs)
    }

    private fun initView(attrs: AttributeSet?) {
        setBackgroundResource(R.drawable.bg_horizontal_switch)
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        val action = ev.action
        if (action == MotionEvent.ACTION_CANCEL || action == MotionEvent.ACTION_UP) {
            dragHelper.cancel()
            return false
        }
        return dragHelper.shouldInterceptTouchEvent(ev)
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        dragHelper.processTouchEvent(event)
        when (event.action) {
            MotionEvent.ACTION_DOWN -> {
                parent.requestDisallowInterceptTouchEvent(true)
            }
            MotionEvent.ACTION_UP -> {
                enableSwitch(event.x <= width / 2)
                ViewCompat.postInvalidateOnAnimation(this)
            }
        }
        return true
    }

    fun enableSwitch(isLeftSelected: Boolean, invokeListener: Boolean = true) {
        this.isLeftSelected = isLeftSelected
        moveSwitch(isLeftSelected)
        if (invokeListener) {
            listener?.onSwitch(isLeftSelected)
        }
    }

    private fun moveSwitch(isLeftSelected: Boolean) {
        val leftPosition = if (isLeftSelected) paddingStart else width / 2
        dragHelper.smoothSlideViewTo(binding.horizontalSwitchThumbCardView, leftPosition, paddingTop)
        ViewCompat.postInvalidateOnAnimation(this)
    }

    override fun computeScroll() {
        if (dragHelper.continueSettling(true)) {
            ViewCompat.postInvalidateOnAnimation(this)
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        var offset: Int = -1
        if (isLeftSelected.not()) {
            offset = (width / 2) - binding.horizontalSwitchThumbCardView.left
        }
        if (offset != -1) {
            binding.horizontalSwitchThumbCardView.offsetLeftAndRight(offset)
            binding.horizontalSwitchThumbCardView.offsetTopAndBottom(paddingTop)
        }
    }

    private val dragHelper by lazy {
        ViewDragHelper.create(this, 1.0f, object : ViewDragHelper.Callback() {
            override fun getOrderedChildIndex(index: Int): Int {
                return indexOfChild(binding.horizontalSwitchThumbCardView)
            }

            override fun tryCaptureView(child: View, pointerId: Int): Boolean {
                return child == binding.horizontalSwitchThumbCardView
            }

            override fun clampViewPositionHorizontal(child: View, left: Int, dx: Int): Int {
                val leftBound = paddingLeft
                val rightBound = width - binding.horizontalSwitchThumbCardView.width - paddingEnd
                return min(max(left, leftBound), rightBound)
            }

            override fun clampViewPositionVertical(child: View, top: Int, dy: Int): Int {
                return min(paddingTop, child.height + paddingTop)
            }
        })
    }

    fun setup(listener: Listener, @StringRes rightSwitchTextResId: Int, @StringRes leftSwitchTextResId: Int) {
        this.listener = listener
        binding.horizontalSwitchLeftTextView.setXmlStyledString(leftSwitchTextResId)
        binding.horizontalSwitchRightTextView.setText(rightSwitchTextResId)
    }

    interface Listener {
        fun onSwitch(isLeftSelected: Boolean)
    }
}
