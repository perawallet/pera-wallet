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

package com.algorand.android.modules.transaction.detail.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentTransactionDetailBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.transaction.detail.domain.model.TransactionDetailPreview
import com.algorand.android.modules.transaction.detail.ui.adapter.TransactionDetailAdapter
import com.algorand.android.utils.browser.openUrl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseTransactionDetailFragment : DaggerBaseFragment(R.layout.fragment_transaction_detail) {

    private val binding by viewBinding(FragmentTransactionDetailBinding::bind)

    abstract val toolbarConfiguration: ToolbarConfiguration

    abstract val transactionDetailViewModel: BaseTransactionDetailViewModel

    abstract val transactionDetailAdapter: TransactionDetailAdapter

    private val transactionDetailPreviewCollector: suspend (TransactionDetailPreview?) -> Unit = { preview ->
        initTransactionDetailPreview(preview)
    }

    protected val transactionDetailTooltipListener = TransactionDetailAdapter.TooltipListener {
        transactionDetailViewModel.setCopyAddressTipShown()
    }

    protected val transactionDetailClickListener = object : TransactionDetailAdapter.ExtrasClickListener {
        override fun onPeraExplorerClick(url: String) {
            context?.openUrl(url)
        }
    }

    protected abstract fun initUi()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        binding.transactionDetailRecyclerView.adapter = transactionDetailAdapter
    }

    protected fun onTransactionDetailClose() {
        transactionDetailViewModel.clearInnerTransactionStackCache()
        nav(NavigationDetailEntryFragmentDirections.actionTransactionDetailNavigationPop())
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            transactionDetailViewModel.transactionDetailPreviewFlow,
            transactionDetailPreviewCollector
        )
    }

    private fun initTransactionDetailPreview(transactionDetailPreview: TransactionDetailPreview?) {
        transactionDetailPreview?.run {
            binding.progressBar.root.isVisible = isLoading
            transactionDetailAdapter.submitList(transactionDetailItemList)
            toolbarTitleResId?.let { titleResId -> getAppToolbar()?.changeTitle(titleResId) }
        }
    }

    companion object {
        const val FIREBASE_EVENT_SCREEN_ID = "screen_transaction_detail"
    }
}
