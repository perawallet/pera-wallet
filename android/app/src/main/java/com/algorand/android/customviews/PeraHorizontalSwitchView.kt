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
import android.view.MotionEvent
import android.view.View
import androidx.annotation.DrawableRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.ViewCompat
import androidx.customview.widget.ViewDragHelper
import com.algorand.android.R
import com.algorand.android.databinding.CustomPeraHorizontalSwitchViewBinding
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.math.max
import kotlin.math.min

class PeraHorizontalSwitchView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private var listener: Listener? = null

    private val binding = viewBinding(CustomPeraHorizontalSwitchViewBinding::inflate)

    private val dragViewHelperCallback = object : ViewDragHelper.Callback() {
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
    }

    private val dragHelper = ViewDragHelper.create(this, 1.0f, dragViewHelperCallback)

    init {
        initRootView()
        initAttributes(attrs)
    }

    private fun initAttributes(attributeSet: AttributeSet?) {
        context.obtainStyledAttributes(attributeSet, R.styleable.PeraHorizontalSwitchView).use { attrs ->
            attrs.getDrawable(R.styleable.PeraHorizontalSwitchView_startOptionIcon)?.let {
                binding.startOptionButton.icon = it
            }
            attrs.getDrawable(R.styleable.PeraHorizontalSwitchView_endOptionIcon).let {
                binding.endOptionButton.icon = it
            }
        }
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        if (ev.action == MotionEvent.ACTION_CANCEL || ev.action == MotionEvent.ACTION_UP) {
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
                triggerListener(event.x)
                ViewCompat.postInvalidateOnAnimation(this)
            }
        }
        return true
    }

    override fun computeScroll() {
        if (dragHelper.continueSettling(true)) {
            ViewCompat.postInvalidateOnAnimation(this)
        }
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        with(binding.horizontalSwitchThumbCardView) {
            offsetLeftAndRight(paddingStart)
            offsetTopAndBottom(paddingTop)
        }
    }

    private fun triggerListener(x: Float) {
        if (x <= width / 2) {
            listener?.onStartOptionActivated().also { moveSwitchToStart() }
        } else {
            listener?.onEndOptionActivated().also { moveSwitchToEnd() }
        }
    }

    fun moveSwitchToStart() {
        moveSwitch(paddingStart).also {
            updateSwitchThumbBackground(R.drawable.bg_pera_horizontal_switch_thumb_start_view)
        }
    }

    fun moveSwitchToEnd() {
        moveSwitch(width / 2).also {
            updateSwitchThumbBackground(R.drawable.bg_pera_horizontal_switch_thumb_end_view)
        }
    }

    private fun updateSwitchThumbBackground(@DrawableRes backgroundResId: Int) {
        binding.horizontalSwitchThumbCardView.setBackgroundResource(backgroundResId)
    }

    private fun moveSwitch(finalLeft: Int) {
        dragHelper.smoothSlideViewTo(binding.horizontalSwitchThumbCardView, finalLeft, paddingTop)
        ViewCompat.postInvalidateOnAnimation(this)
    }

    private fun initRootView() {
        setBackgroundResource(R.drawable.bg_pera_horizontal_switch_view)
        with(binding) {
            startOptionButton.setOnClickListener {
                moveSwitchToStart()
                listener?.onStartOptionActivated()
            }
            endOptionButton.setOnClickListener {
                moveSwitchToEnd()
                listener?.onEndOptionActivated()
            }
        }
    }

    interface Listener {
        fun onStartOptionActivated()
        fun onEndOptionActivated()
    }
}
