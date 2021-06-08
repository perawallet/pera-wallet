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
import android.content.res.ColorStateList
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.motion.widget.MotionLayout
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.databinding.CustomSendReceiveTabbarBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SendReceiveTabBarView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : MotionLayout(context, attrs) {

    private var isSendRequestOpened: Boolean = false
    private var listener: Listener? = null

    private val binding = viewBinding(CustomSendReceiveTabbarBinding::inflate)

    init {
        binding.sendReceiveActionButton.setOnClickListener { handleButtonClick() }
        binding.sendButtton.setOnClickListener { listener?.onSendClick() }
        binding.receiveButton.setOnClickListener { listener?.onRequestClick() }
    }

    fun hideWithoutAnimation() {
        visibility = View.GONE
        startHidingAnimation()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    private fun startHidingAnimation() {
        setButtonUI(showClosedState = false)
        transitionToStart()
        isSendRequestOpened = false
    }

    private fun startOpeningAnimation() {
        setButtonUI(showClosedState = true)
        transitionToEnd()
        isSendRequestOpened = true
    }

    private fun handleButtonClick() {
        if (isSendRequestOpened) {
            startHidingAnimation()
        } else {
            startOpeningAnimation()
        }
    }

    private fun setButtonUI(showClosedState: Boolean) {
        val iconResId: Int
        val backgroundColorResId: Int
        val iconTintResId: Int

        if (showClosedState) {
            iconResId = R.drawable.ic_close
            backgroundColorResId = R.color.mainBottomCancelBackgroundColor
            iconTintResId = R.color.gray_42
        } else {
            iconResId = R.drawable.ic_send_request
            backgroundColorResId = R.color.colorPrimary
            iconTintResId = R.color.tertiaryBackground
        }

        binding.sendReceiveActionButton.setIconResource(iconResId)
        binding.sendReceiveActionButton.setBackgroundColor(ContextCompat.getColor(context, backgroundColorResId))
        binding.sendReceiveActionButton.iconTint =
            ColorStateList.valueOf(ContextCompat.getColor(context, iconTintResId))
    }

    interface Listener {
        fun onSendClick()
        fun onRequestClick()
    }
}
