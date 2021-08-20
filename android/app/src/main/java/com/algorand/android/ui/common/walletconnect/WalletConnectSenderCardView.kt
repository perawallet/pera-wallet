/*
 * Copyright 2019 Algorand, Inc.
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

package com.algorand.android.ui.common.walletconnect

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.setPadding
import com.algorand.android.R
import com.algorand.android.databinding.CustomWalletConnectSenderViewBinding
import com.algorand.android.models.BaseAppCallTransaction
import com.algorand.android.models.WalletConnectSenderInfo
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectSenderCardView(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomWalletConnectSenderViewBinding::inflate)

    init {
        initRootLayout()
    }

    fun initSender(senderInfo: WalletConnectSenderInfo) {
        with(binding) {
            root.visibility = View.VISIBLE
            with(senderInfo) {
                senderNameTextView.text = senderAccountAddress
                if (senderTypeImageResId != null) {
                    senderTypeImageView.setImageResource(senderTypeImageResId)
                }
                initOnComplete(onComplete)
                initRekeyToAddress(rekeyToAccountAddress)
                initApplicationId(applicationId)
            }
        }
    }

    private fun initOnComplete(onComplete: BaseAppCallTransaction.AppOnComplete) {
        binding.onCompleteTextView.setText(onComplete.displayTextResId)
    }

    private fun initApplicationId(appId: Long?) {
        if (appId == null) return
        with(binding) {
            applicationIdTextView.text = appId.toString()
            applicationIdGroup.visibility = View.VISIBLE
        }
    }

    private fun initRekeyToAddress(address: String?) {
        if (!address.isNullOrBlank()) {
            with(binding) {
                rekeyToTextView.text = address
                rekeyGroup.visibility = View.VISIBLE
            }
        }
    }

    private fun initRootLayout() {
        setBackgroundResource(R.drawable.bg_small_shadow)
        setPadding(resources.getDimensionPixelSize(R.dimen.keyline_1_plus_4_dp))
    }
}
