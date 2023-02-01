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

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.DialogLedgerLoadingBinding
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.extensions.wrapWithBrackets
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.viewbinding.viewBinding

// TODO find a way to put into home_navigation
class LedgerLoadingDialog : BaseBottomSheet(
    layoutResId = R.layout.dialog_ledger_loading
) {

    private var listener: Listener? = null

    private val binding by viewBinding(DialogLedgerLoadingBinding::bind)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initTransactionIndicator()
        initDescriptionText()
        initCancelButton()
    }

    fun updateTransactionIndicator(transactionIndex: Int?) {
        if (transactionIndex == null || view == null) return
        arguments?.putInt(CURRENT_TRANSACTION_INDEX, transactionIndex)

        with(binding) {
            ledgerTransactionIndicatorLabel.apply {
                text = getString(
                    R.string.signing_index_out_of_count,
                    transactionIndex,
                    arguments?.getInt(TOTAL_TRANSACTION_COUNT)
                )
            }
            ledgerTransactionIndicator.setProgress(transactionIndex, true)
        }
    }

    private fun initTransactionIndicator() {
        val currentTransactionIndex = arguments?.getInt(CURRENT_TRANSACTION_INDEX)
        val totalTransactionCount = arguments?.getInt(TOTAL_TRANSACTION_COUNT)
        val isTransactionIndicatorVisible = arguments?.getBoolean(IS_TRANSACTION_INDICATOR_VISIBLE) ?: false
        if (currentTransactionIndex == null || totalTransactionCount == null || !isTransactionIndicatorVisible) return
        with(binding) {
            ledgerTransactionIndicator.apply {
                max = totalTransactionCount
                setProgress(currentTransactionIndex, true)
                show()
            }
            ledgerTransactionIndicatorLabel.apply {
                text = getString(
                    R.string.signing_index_out_of_count,
                    currentTransactionIndex,
                    totalTransactionCount
                )
                show()
            }
        }
    }

    private fun initDescriptionText() {
        val ledgerName = arguments?.getString(LEDGER_NAME_KEY)?.wrapWithBrackets().orEmpty()
        binding.descriptionTextView.text = context?.getXmlStyledString(
            stringResId = R.string.please_make_sure,
            replacementList = listOf("ledger_name" to ledgerName)
        )
    }

    private fun initCancelButton() {
        binding.cancelButton.setOnClickListener { onDismissDialog(true) }
    }

    /**
     * We should stop resources only if user clicks `Cancel` button, otherwise we should just dismiss bottom sheet
     * without taking any action on [TransactionManager] side
     */
    private fun onDismissDialog(shouldStopResources: Boolean) {
        listener?.onLedgerLoadingCancelled(shouldStopResources)
        dismissAllowingStateLoss()
    }

    fun interface Listener {
        fun onLedgerLoadingCancelled(shouldStopResources: Boolean)
    }

    companion object {
        private const val LEDGER_NAME_KEY = "ledger_name"
        private const val CURRENT_TRANSACTION_INDEX = "current_transaction_index"
        private const val TOTAL_TRANSACTION_COUNT = "total_transaction_count"
        private const val IS_TRANSACTION_INDICATOR_VISIBLE = "is_transaction_indicator_visible"

        fun createLedgerLoadingDialog(
            ledgerName: String?,
            listener: Listener,
            currentTransactionIndex: Int? = null,
            totalTransactionCount: Int? = null,
            isTransactionIndicatorVisible: Boolean = false
        ): LedgerLoadingDialog {
            return LedgerLoadingDialog().apply {
                this.listener = listener
                arguments = Bundle().apply {
                    putString(LEDGER_NAME_KEY, ledgerName)
                    if (currentTransactionIndex != null) putInt(CURRENT_TRANSACTION_INDEX, currentTransactionIndex)
                    if (totalTransactionCount != null) putInt(TOTAL_TRANSACTION_COUNT, totalTransactionCount)
                    putBoolean(IS_TRANSACTION_INDICATOR_VISIBLE, isTransactionIndicatorVisible)
                }
            }
        }
    }
}
