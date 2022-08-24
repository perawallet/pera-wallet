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

package com.algorand.android.modules.transaction.detail.ui.standardtransaction

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.transaction.detail.ui.BaseTransactionDetailFragment
import com.algorand.android.modules.transaction.detail.ui.adapter.TransactionDetailAdapter
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.toShortenedAddress
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class StandardTransactionDetailFragment : BaseTransactionDetailFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    override val transactionDetailViewModel by viewModels<StandardTransactionDetailViewModel>()

    private val transactionDetailLongClickListener = object : TransactionDetailAdapter.LongPressListener {
        override fun onAddressLongClick(publicKey: String) {
            context?.copyToClipboard(publicKey, showToast = false)
            showTopToast(getString(R.string.address_copied_to_clipboard), publicKey.toShortenedAddress())
        }

        override fun onTransactionIdLongClick(transactionId: String) {
            context?.copyToClipboard(transactionId)
        }
    }

    private val accountItemClickListener = TransactionDetailAdapter.AccountItemListener {
        onAddButtonClicked(it)
    }

    private fun navToInnerTransactionFragment() {
        nav(
            StandardTransactionDetailFragmentDirections
                .actionStandardTransactionDetailFragmentToInnerTransactionDetailFragment(
                    transactionId = transactionDetailViewModel.transactionId,
                    publicKey = transactionDetailViewModel.publicKey
                )
        )
    }

    override val transactionDetailAdapter = TransactionDetailAdapter(
        extrasExtrasClickListener = transactionDetailClickListener,
        longPressListener = transactionDetailLongClickListener,
        tooltipListener = transactionDetailTooltipListener,
        accountItemListener = accountItemClickListener
    )

    override fun initUi() {
        configureToolbar()
    }

    private fun configureToolbar() {
        if (transactionDetailViewModel.shouldShowCloseButton) {
            getAppToolbar()?.apply {
                addButtonToEnd(button = TextButton(R.string.close, onClick = ::onTransactionDetailClose))
                configureStartButton(resId = R.drawable.ic_left_arrow, clickAction = ::navBack)
            }
        }
    }

    private fun onAddButtonClicked(address: String) {
        nav(
            StandardTransactionDetailFragmentDirections
                .actionStandardTransactionDetailFragmentToContactAdditionNavigation(contactPublicKey = address)
        )
    }
}
