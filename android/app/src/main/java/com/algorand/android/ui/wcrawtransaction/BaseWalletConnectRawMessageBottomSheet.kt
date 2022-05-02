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

package com.algorand.android.ui.wcrawtransaction

import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectRawMessageBinding
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

abstract class BaseWalletConnectRawMessageBottomSheet :
    DaggerBaseBottomSheet(R.layout.bottom_sheet_wallet_connect_raw_message, true, null) {

    private val binding by viewBinding(BottomSheetWalletConnectRawMessageBinding::bind)

    private val rawTextMessage
        get() = binding.rawMessageTextView.text

    private var transactionRequestListener: TransactionRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        transactionRequestListener = parentFragment?.parentFragment as? TransactionRequestAction
    }

    abstract fun setRawMessage(textView: TextView)

    open fun setCloseButton(closeButton: MaterialButton) {
        closeButton.setOnClickListener { transactionRequestListener?.onNavigateBack() }
    }

    open fun setCopyButton(copyButton: MaterialButton) {
        copyButton.setOnClickListener { context?.copyToClipboard(rawTextMessage) }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setRawMessage(binding.rawMessageTextView)
        setCloseButton(binding.closeButton)
        setCopyButton(binding.copyButton)
    }
}
