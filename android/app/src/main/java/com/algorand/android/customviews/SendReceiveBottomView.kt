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
import android.view.Gravity.CENTER_HORIZONTAL
import android.widget.LinearLayout
import com.algorand.android.databinding.CustomSendReceiveBottomViewBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SendReceiveBottomView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private var listener: Listener? = null

    private val binding = viewBinding(CustomSendReceiveBottomViewBinding::inflate)

    init {
        gravity = CENTER_HORIZONTAL
        initButtons()
    }

    private fun initButtons() {
        binding.sendButton.setOnClickListener { listener?.onSendClick() }
        binding.receiveButton.setOnClickListener { listener?.onReceiveClick() }
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    interface Listener {
        fun onSendClick()
        fun onReceiveClick()
    }
}
