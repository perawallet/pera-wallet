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

import android.content.DialogInterface
import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.DialogLedgerLoadingBinding
import com.algorand.android.utils.extensions.wrapWithBrackets
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

// TODO find a way to put into home_navigation
class LedgerLoadingDialog : BaseBottomSheet(R.layout.dialog_ledger_loading) {

    private var listener: Listener? = null

    private val binding by viewBinding(DialogLedgerLoadingBinding::bind)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listener = parentFragment as? Listener
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            cancelButton.setOnClickListener { dismissAllowingStateLoss() }
            val ledgerName = arguments?.getString(LEDGER_NAME_KEY)?.wrapWithBrackets().orEmpty()
            descriptionTextView.text = context?.getXmlStyledString(
                stringResId = R.string.please_make_sure,
                replacementList = listOf("ledger_name" to ledgerName)
            )
        }
    }

    override fun onDismiss(dialog: DialogInterface) {
        listener?.onLedgerLoadingCancelled()
        super.onDismiss(dialog)
    }

    interface Listener {
        fun onLedgerLoadingCancelled()
    }

    companion object {
        private const val LEDGER_NAME_KEY = "ledger_name"

        fun createLedgerLoadingDialog(ledgerName: String?): LedgerLoadingDialog {
            return LedgerLoadingDialog().apply { arguments = Bundle().apply { putString(LEDGER_NAME_KEY, ledgerName) } }
        }
    }
}
