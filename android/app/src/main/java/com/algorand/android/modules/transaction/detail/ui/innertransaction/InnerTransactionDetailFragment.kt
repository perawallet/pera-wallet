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

package com.algorand.android.modules.transaction.detail.ui.innertransaction

import android.os.Bundle
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.ui.BaseTransactionDetailFragment
import com.algorand.android.modules.transaction.detail.ui.adapter.TransactionDetailAdapter
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class InnerTransactionDetailFragment : BaseTransactionDetailFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.inner_transactions,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onNavBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val onBackPressedCallback = object : OnBackPressedCallback(true) {
        override fun handleOnBackPressed() {
            onNavBack()
        }
    }

    override val transactionDetailViewModel by viewModels<InnerTransactionDetailViewModel>()

    private val innerTransactionListener = object : TransactionDetailAdapter.InnerTransactionListener {
        override fun onStandardTransactionClick(transaction: BaseTransactionDetail) {
            navToStandardTransactionDetail(transaction)
        }

        override fun onApplicationCallClick(transaction: BaseTransactionDetail.ApplicationCallTransaction) {
            navToApplicationCallTransactionDetail(transaction)
        }
    }

    override val transactionDetailAdapter = TransactionDetailAdapter(
        innerTransactionListener = innerTransactionListener
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity?.onBackPressedDispatcher?.addCallback(viewLifecycleOwner, onBackPressedCallback)
    }

    override fun initUi() {
        configureToolbar()
    }

    private fun configureToolbar() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.close, onClick = ::onTransactionDetailClose))
    }

    private fun navToApplicationCallTransactionDetail(transaction: BaseTransactionDetail.ApplicationCallTransaction) {
        nav(
            InnerTransactionDetailFragmentDirections
                .actionInnerTransactionDetailFragmentToApplicationCallTransactionDetailFragment(
                    transactionId = transactionDetailViewModel.transactionId,
                    accountAddress = transactionDetailViewModel.accountAddress,
                    showCloseButton = true,
                    transaction = transaction
                )
        )
    }

    private fun navToStandardTransactionDetail(transaction: BaseTransactionDetail) {
        nav(
            InnerTransactionDetailFragmentDirections
                .actionInnerTransactionDetailFragmentToStandardTransactionDetailFragment(
                    transactionId = transactionDetailViewModel.transactionId,
                    accountAddress = transactionDetailViewModel.accountAddress,
                    showCloseButton = true,
                    transaction = transaction
                )
        )
    }

    private fun onNavBack() {
        transactionDetailViewModel.popInnerTransactionFromStackCache()
        navBack()
    }
}
