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

package com.algorand.android.modules.swap.ledger.signwithledger.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetSignWithLedgerBinding
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setFragmentNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SignWithLedgerBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_sign_with_ledger) {

    private val signWithLedgerViewModel by viewModels<SignWithLedgerViewModel>()

    private val binding by viewBinding(BottomSheetSignWithLedgerBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        val transactionCount = signWithLedgerViewModel.transactionCount
        with(binding) {
            transactionDescriptionTextView.text = context?.getXmlStyledString(
                stringResId = R.string.we_ve_detected_that_you,
                replacementList = listOf("transaction_count" to transactionCount.toString())
            )
            signTransactionButton.apply {
                text = resources.getQuantityString(
                    R.plurals.sign_transaction,
                    transactionCount,
                    transactionCount
                )
                setOnClickListener {
                    setFragmentNavigationResult(SIGN_WITH_LEDGER_APPROVED_KEY, true)
                    dismissAllowingStateLoss()
                }
            }
        }
    }

    companion object {
        const val SIGN_WITH_LEDGER_APPROVED_KEY = "sign_with_ledger_approved_key"
    }
}
