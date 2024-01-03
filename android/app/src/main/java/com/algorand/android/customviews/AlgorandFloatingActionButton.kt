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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.constraintlayout.motion.widget.MotionLayout
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomAlgorandFabBinding
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class AlgorandFloatingActionButton @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : MotionLayout(context, attrs) {

    private val binding = viewBinding(CustomAlgorandFabBinding::inflate)

    private var listener: Listener? = null

    private var isExpanded by Delegates.observable(false) { _, _, newValue ->
        listener?.onStateChange(newValue)
    }

    init {
        initUi()
    }

    fun setBuyAlgoActionButtonVisibility(isVisible: Boolean) {
        binding.buyAlgoActionButton.isVisible = isVisible
    }

    private fun initUi() {
        with(binding) {
            receiveActionButton.setOnClickListener { listener?.onReceiveClick() }
            sendActionButton.setOnClickListener { listener?.onSendClick() }
            buyAlgoActionButton.setOnClickListener { listener?.onBuyAlgoClick() }
            openCloseActionButton.setOnClickListener { handleButtonClick() }
        }
    }

    private fun handleButtonClick() {
        updateOpenCloseButtonDrawable()
        animateView()
        isExpanded = !isExpanded
    }

    private fun updateOpenCloseButtonDrawable() {
        val buttonIconRes = if (isExpanded) R.drawable.ic_arrow_swap else R.drawable.ic_close
        binding.openCloseActionButton.setImageResource(buttonIconRes)
    }

    private fun animateView() {
        if (isExpanded) transitionToStart() else transitionToEnd()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    interface Listener {
        fun onReceiveClick()
        fun onSendClick()
        fun onBuyAlgoClick()
        fun onStateChange(isExtended: Boolean)
    }
}
