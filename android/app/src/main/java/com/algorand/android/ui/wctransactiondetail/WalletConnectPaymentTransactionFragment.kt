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

package com.algorand.android.ui.wctransactiondetail

import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.BasePaymentTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectPeerMeta
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectPaymentTransactionFragment : BaseWalletConnectTransactionDetailFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        titleResId = R.string.transaction_request
    )

    override val fragmentConfiguration: FragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    private val walletConnectPaymentTransactionViewModel: WalletConnectPaymentTransactionViewModel by viewModels()
    private val args: WalletConnectPaymentTransactionFragmentArgs by navArgs()

    override val transaction: BasePaymentTransaction
        get() = args.transaction

    override val peerMeta: WalletConnectPeerMeta
        get() = transaction.peerMeta

    override fun initUi() {
        super.initUi()
        with(walletConnectPaymentTransactionViewModel) {
            getAmountInfo(transaction)
            getTransactionInfo(transaction)
            getExtras(transaction)
        }
    }

    override fun initObservers() {
        with(walletConnectPaymentTransactionViewModel) {
            amountInfoLiveData.observe(viewLifecycleOwner, amountInfoObserver)
            transactionInfoLiveData.observe(viewLifecycleOwner, transactionInfoObserver)
            extrasLiveData.observe(viewLifecycleOwner, extrasObserver)
        }
    }
}
