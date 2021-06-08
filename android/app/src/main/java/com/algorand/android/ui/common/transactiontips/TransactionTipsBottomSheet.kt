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

package com.algorand.android.ui.common.transactiontips

import android.app.Dialog
import android.os.Bundle
import android.text.style.ForegroundColorSpan
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.FragmentTransactionTipsBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.openTransactionInfoUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class TransactionTipsBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.fragment_transaction_tips,
    fullPageNeeded = false,
    firebaseEventScreenId = null,
) {

    private val binding by viewBinding(FragmentTransactionTipsBinding::bind)

    private val transactionTipsViewModel: TransactionTipsViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(R.string.transacting_tips)

    override fun getTheme() = R.style.BottomSheetDialogTheme_Secondary

    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val dialog = super.onCreateDialog(savedInstanceState)
        dialog.setCanceledOnTouchOutside(false)
        return dialog
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setupForMoreInformationText()
        setupSecondDescriptionText()
        binding.moreInfoTextView.setOnClickListener { onMoreInformationClick() }
        binding.positiveButton.setOnClickListener { onPositiveButtonClick() }
    }

    private fun setupToolbar() {
        binding.toolbar.configure(toolbarConfiguration)
    }

    private fun setupForMoreInformationText() {
        binding.moreInfoTextView.apply {
            val tapHereColor = ContextCompat.getColor(context, R.color.linkTextColor)
            text = context.getXmlStyledString(
                stringResId = R.string.for_more_information_on,
                customAnnotations = listOf("tap_here_color" to ForegroundColorSpan(tapHereColor))
            )
        }
    }

    private fun setupSecondDescriptionText() {
        binding.secondDescriptionTextView.apply {
            val highlightColor = ContextCompat.getColor(context, R.color.orange_E0)
            text = context.getXmlStyledString(
                stringResId = R.string.exchanges_change_their,
                customAnnotations = listOf("highlight_color" to ForegroundColorSpan(highlightColor))
            )
        }
    }

    private fun onMoreInformationClick() {
        context?.openTransactionInfoUrl()
    }

    private fun closeBottomSheet() {
        transactionTipsViewModel.setFirstTransactionPreference()
        navBack()
    }

    private fun onPositiveButtonClick() {
        closeBottomSheet()
    }
}
