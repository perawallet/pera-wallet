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

import android.content.DialogInterface
import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.DialogLedgerLoadingBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding

// TODO find a way to put into home_navigation
class LedgerLoadingDialog : BaseBottomSheet(R.layout.dialog_ledger_loading) {

    private var listener: Listener? = null

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.ledger_approval)

    private val binding by viewBinding(DialogLedgerLoadingBinding::bind)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listener = parentFragment as? Listener
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        binding.cancelButton.setOnClickListener { dismissAllowingStateLoss() }
    }

    override fun onDismiss(dialog: DialogInterface) {
        listener?.onLedgerLoadingCancelled()
        super.onDismiss(dialog)
    }

    interface Listener {
        fun onLedgerLoadingCancelled()
    }

    companion object {
        fun createLedgerLoadingDialog(): LedgerLoadingDialog {
            return LedgerLoadingDialog()
        }
    }
}
