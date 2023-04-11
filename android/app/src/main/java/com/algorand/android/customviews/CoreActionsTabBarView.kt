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
import androidx.constraintlayout.motion.widget.MotionLayout
import com.algorand.android.R
import com.algorand.android.databinding.CustomCoreActionsTabBarBinding
import com.algorand.android.utils.viewbinding.viewBinding

class CoreActionsTabBarView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : MotionLayout(context, attrs) {

    var isCoreActionsOpened: Boolean = false
        private set

    private var listener: Listener? = null

    private val binding = viewBinding(CustomCoreActionsTabBarBinding::inflate)

    init {
        with(binding) {
            coreActionsButton.setOnClickListener { onCoreActionsButtonClick() }
            sendButton.setOnClickListener { listener?.onSendClick() }
            receiveButton.setOnClickListener { listener?.onReceiveClick() }
            buySellButton.setOnClickListener { listener?.onBuySellClick() }
            scanQrButton.setOnClickListener { listener?.onScanQRClick() }
            swapButton.setOnClickListener { listener?.onSwapClick() }
            backgroundColorView.setOnClickListener { startHidingAnimation() }
        }
    }

    fun hideWithoutAnimation() {
        visibility = GONE
        progress = 0F
        startHidingAnimation()
    }

    fun hideWithAnimation() {
        if (isCoreActionsOpened) {
            startHidingAnimation()
        }
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun setCoreActionButtonEnabled(isEnabled: Boolean) {
        binding.coreActionsButton.isEnabled = isEnabled
    }

    private fun startHidingAnimation() {
        transitionToStart()
        isCoreActionsOpened = false
        setCoreActionsButtonIcon()
        listener?.onCoreActionsClick(isCoreActionsOpened)
    }

    private fun startOpeningAnimation() {
        transitionToEnd()
        isCoreActionsOpened = true
        setCoreActionsButtonIcon()
        listener?.onCoreActionsClick(isCoreActionsOpened)
    }

    private fun onCoreActionsButtonClick() {
        if (isCoreActionsOpened) {
            startHidingAnimation()
        } else {
            startOpeningAnimation()
        }
    }

    private fun setCoreActionsButtonIcon() {
        binding.coreActionsButton.setIconResource(
            if (isCoreActionsOpened) {
                R.drawable.ic_close
            } else {
                R.drawable.ic_pera
            }
        )
    }

    interface Listener {
        fun onSendClick()
        fun onReceiveClick()
        fun onBuySellClick()
        fun onScanQRClick()
        fun onCoreActionsClick(isCoreActionsOpen: Boolean)
        fun onSwapClick()
    }
}
