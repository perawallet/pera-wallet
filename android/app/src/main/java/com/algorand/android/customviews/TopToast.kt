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

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.drawable.ColorDrawable
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.Gravity
import android.view.View.OnTouchListener
import android.widget.FrameLayout
import android.widget.PopupWindow
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.view.GestureDetectorCompat
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomTopToastBinding
import com.algorand.android.utils.FlingDetector
import com.algorand.android.utils.viewbinding.viewBinding

class TopToast(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private val popupWindow: PopupWindow

    private val binding = viewBinding(CustomTopToastBinding::inflate)
    private val dismissHandler = Handler(Looper.getMainLooper())

    private val flingListener = object : FlingDetector.FlingDetectorListener {
        override fun onSwipeUp(): Boolean {
            dismissAnimated()
            return true
        }
    }

    private val gestureDetector = GestureDetectorCompat(context, FlingDetector(flingListener))

    // popUpWindow.isShowing method shouldn't be used as a switch to show and hide,
    // because if you haven’t called the showAsDropDown method, the isShowing () return value must be false.
    private var isPopupWindowVisible: Boolean = false

    @SuppressLint("ClickableViewAccessibility")
    private val onPopupWindowTouchListener = OnTouchListener { _, event -> gestureDetector.onTouchEvent(event) }

    init {
        initRootLayout()
        popupWindow = PopupWindow(context).apply {
            animationStyle = R.style.TopToastAnimationStyle
            contentView = binding.root
            setBackgroundDrawable(ColorDrawable(ContextCompat.getColor(context, R.color.transparent)))
            this.setTouchInterceptor(onPopupWindowTouchListener)
        }
    }

    fun show(title: String?, description: String?, displayTime: Long = DISPLAY_TIME) {
        if (title.isNullOrBlank() && description.isNullOrBlank()) return

        if (isPopupWindowVisible) {
            dismissAnimated {
                showPopupWindow(title, description, displayTime)
            }
        } else {
            showPopupWindow(title, description, displayTime)
        }
    }

    private fun showPopupWindow(title: String?, description: String?, displayTime: Long) {
        with(binding) {
            showTextIfTextIsNotBlank(titleTextView, title)
            showTextIfTextIsNotBlank(descriptionTextView, description)
        }

        popupWindow.showAtLocation(this@TopToast, Gravity.TOP or Gravity.CENTER_HORIZONTAL, 0, 0)
        isPopupWindowVisible = true
        dismissAfterTime(displayTime)
    }

    private fun showTextIfTextIsNotBlank(textView: TextView, text: String?) {
        textView.apply {
            this.text = text
            isVisible = !text.isNullOrBlank()
        }
    }

    private fun dismissAfterTime(displayTime: Long) {
        dismissHandler.postDelayed({ dismissAnimated() }, displayTime)
    }

    fun dismissAnimated(onDismissListener: (() -> Unit)? = null) {
        popupWindow.apply {
            setOnDismissListener {
                isPopupWindowVisible = false
                onDismissListener?.invoke()
            }
            dismissHandler.removeCallbacksAndMessages(null)
            dismiss()
        }
    }

    private fun initRootLayout() {
        layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
    }

    companion object {
        private const val DISPLAY_TIME = 2000L
    }
}
