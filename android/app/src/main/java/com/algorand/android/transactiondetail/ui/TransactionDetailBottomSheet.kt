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

package com.algorand.android.transactiondetail.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetTransactionDetailBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.transactiondetail.domain.model.TransactionDetailPreview
import com.algorand.android.transactiondetail.ui.adapter.TransactionDetailAdapter
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class TransactionDetailBottomSheet : DaggerBaseBottomSheet(
    R.layout.bottom_sheet_transaction_detail,
    fullPageNeeded = true,
    firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
) {

    private val transactionDetailViewModel: TransactionDetailViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.transaction_detail,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    private val binding by viewBinding(BottomSheetTransactionDetailBinding::bind)

    private val transactionDetailPreviewCollector: suspend (TransactionDetailPreview?) -> Unit = { preview ->
        initTransactionDetailPreview(preview)
    }

    private val transactionDetailTooltipListener = object : TransactionDetailAdapter.TooltipListener {
        override fun onTooltipShowed() {
            transactionDetailViewModel.setCopyAddressTipShown()
        }
    }

    private val transactionDetailClickListener = object : TransactionDetailAdapter.ClickListener {
        override fun onAlgoExplorerClick(url: String) {
            context?.openUrl(url)
        }

        override fun onGoalSeekerClick(url: String) {
            context?.openUrl(url)
        }

        override fun onContactAdditionClick(publicKey: String) {
            onAddButtonClicked(publicKey)
        }
    }

    private val transactionDetailLongClickListener = object : TransactionDetailAdapter.LongClickListener {
        override fun onAddressLongClick(publicKey: String) {
//            TODO "Not yet implemented"
        }

        override fun onTransactionIdLongClick(transactionId: String) {
            context?.copyToClipboard(transactionId)
        }
    }

    private val transactionDetailAdapter = TransactionDetailAdapter(
        clickListener = transactionDetailClickListener,
        longClickListener = transactionDetailLongClickListener,
        tooltipListener = transactionDetailTooltipListener
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.toolbar.configure(toolbarConfiguration)
        initObservers()
        binding.transactionDetailRecyclerView.adapter = transactionDetailAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            transactionDetailViewModel.transactionDetailPreviewFlow.collectLatest(transactionDetailPreviewCollector)
        }
    }

    private fun initTransactionDetailPreview(transactionDetailPreview: TransactionDetailPreview?) {
        if (transactionDetailPreview != null) {
            binding.progressBar.root.isVisible = transactionDetailPreview.isLoading
            transactionDetailAdapter.submitList(transactionDetailPreview.transactionDetailItemList)
        }
    }

    private fun onAddButtonClicked(address: String) {
        nav(
            TransactionDetailBottomSheetDirections.actionTransactionDetailBottomSheetToAddContactFragment(
                contactPublicKey = address
            )
        )
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_transaction_detail"
    }
}
