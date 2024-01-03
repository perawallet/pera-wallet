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

package com.algorand.android.ui.wcatomictransactions

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentWalletConnectAtomicTransactionsBinding
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionAdapter
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlin.properties.Delegates

@AndroidEntryPoint
class WalletConnectAtomicTransactionsFragment : DaggerBaseFragment(
    R.layout.fragment_wallet_connect_atomic_transactions
) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = { listener?.onNavigateBack() },
        titleResId = R.string.multiple_transaction_request
    )

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentWalletConnectAtomicTransactionsBinding::bind)
    private val args by navArgs<WalletConnectAtomicTransactionsFragmentArgs>()
    private val walletConnectAtomicTransactionViewModel: WalletConnectAtomicTransactionViewModel by viewModels()

    private val transactionAdapterListener = object : WalletConnectTransactionAdapter.Listener {
        override fun onSingleTransactionClick(transaction: BaseWalletConnectTransaction) {
            listener?.onNavigate(
                WalletConnectAtomicTransactionsFragmentDirections
                    .actionWalletConnectAtomicTransactionsFragmentToTransactionRequestDetailFragment(transaction)
            )
        }
    }

    private var transactionList by Delegates.observable<List<BaseWalletConnectTransaction>?>(null) { _, _, newValue ->
        if (!newValue.isNullOrEmpty()) setTransactionItems(newValue)
    }

    private val transactionAdapter = WalletConnectTransactionAdapter(transactionAdapterListener)

    private var listener: TransactionRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment?.parentFragment as? TransactionRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        transactionList = args.transactionList.toList()
    }

    private fun initUi() {
        with(binding) {
            listener?.hideButtons()
            customToolbar.configure(toolbarConfiguration)
            transactionRequestsRecyclerView.adapter = transactionAdapter
        }
    }

    private fun setTransactionItems(transactionList: List<BaseWalletConnectTransaction>) {
        val groupId = transactionList.firstOrNull()?.groupId
        val transactionItemList = walletConnectAtomicTransactionViewModel.createAtomicTransactionListItems(
            transactionList,
            groupId
        )
        transactionAdapter.submitList(transactionItemList)
    }
}
