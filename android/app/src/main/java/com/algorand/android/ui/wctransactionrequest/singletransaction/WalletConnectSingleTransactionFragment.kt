/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.wctransactionrequest.singletransaction

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.WalletConnectSingleTransactionShortDetailView
import com.algorand.android.databinding.FragmentWalletConnectSingleTransactionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TransactionRequestAction
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectSingleTransactionFragment : BaseFragment(
    R.layout.fragment_wallet_connect_single_transaction
) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val walletConnectSingleTransactionViewModel: WalletConnectSingleTransactionViewModel by viewModels()

    private val args: WalletConnectSingleTransactionFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentWalletConnectSingleTransactionBinding::bind)

    private val showTransactionDetailListener = object : WalletConnectSingleTransactionShortDetailView.Listener {
        override fun onShowTransactionDetailClick() {
            listener?.onNavigate(
                WalletConnectSingleTransactionFragmentDirections
                    .actionWalletConnectSingleTransactionFragmentToTransactionRequestDetailFragment(
                        args.transaction.transaction
                    )
            )
        }
    }

    private var listener: TransactionRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment?.parentFragment as? TransactionRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        listener?.showButtons()
        initToolbar()
        setTransactionAmount()
        initTransactionAbstraction()
    }

    private fun initToolbar() {
        val screenTitleRes = walletConnectSingleTransactionViewModel.buildToolbarTitleRes(args.transaction.transaction)
        binding.customToolbar.changeTitle(screenTitleRes)
    }

    private fun setTransactionAmount() {
        val transactionShortAmount = walletConnectSingleTransactionViewModel.buildTransactionAmount(
            args.transaction.transaction
        )
        binding.transactionAssetInfoView.setTransactionShortAmount(transactionShortAmount)
    }

    private fun initTransactionAbstraction() {
        val transactionShortDetail = walletConnectSingleTransactionViewModel.buildTransactionShortDetail(
            args.transaction.transaction
        )
        binding.transactionShortDetailView.setTransactionShortDetail(
            transactionShortDetail,
            showTransactionDetailListener
        )
    }
}
