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
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.isVisible
import androidx.core.view.updateLayoutParams
import com.algorand.android.R
import com.algorand.android.databinding.CustomAccountCopyQrViewBinding
import com.algorand.android.models.AccountIcon
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.viewbinding.viewBinding

class AccountCopyQrView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomAccountCopyQrViewBinding::inflate)

    private var listener: Listener? = null

    init {
        initAttributes(attrs)
        initUi()
    }

    fun setAccountIcon(accountIcon: AccountIcon?) {
        accountIcon?.let { binding.accountIconImageView.setAccountIcon(it) }
    }

    fun setAccountName(name: String) {
        binding.accountNameTextView.text = name
    }

    fun hideSelectedAccountTextView() {
        binding.selectedAccountLabelTextView.hide()
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.AccountCopyQrView).use {
            it.getBoolean(R.styleable.AccountCopyQrView_isTitleVisible, true).let { isTitleVisible ->
                binding.selectedAccountLabelTextView.isVisible = isTitleVisible
            }
            it.getDimension(R.styleable.AccountCopyQrView_accountIconSize, -1f).let { iconSize ->
                if (iconSize != -1f) {
                    binding.accountIconImageView.updateLayoutParams<LayoutParams> {
                        width = iconSize.toInt()
                        height = iconSize.toInt()
                    }
                }
            }
        }
    }

    private fun initUi() {
        with(binding) {
            copyButton.setOnClickListener { listener?.onCopyClick() }
            showQrButton.setOnClickListener { listener?.onQrClick() }
        }
    }

    interface Listener {
        fun onCopyClick()
        fun onQrClick()
    }
}
