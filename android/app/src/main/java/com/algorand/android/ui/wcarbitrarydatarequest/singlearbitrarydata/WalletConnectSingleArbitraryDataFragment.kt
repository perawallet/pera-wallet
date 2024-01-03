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

package com.algorand.android.ui.wcarbitrarydatarequest.singlearbitrarydata

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.WalletConnectSingleArbitraryDataShortDetailView
import com.algorand.android.databinding.FragmentWalletConnectSingleArbitraryDataBinding
import com.algorand.android.models.ArbitraryDataRequestAction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectSingleArbitraryDataFragment : BaseFragment(
    R.layout.fragment_wallet_connect_single_arbitrary_data
) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.arbitrary_data_request)

    private val walletConnectSingleArbitraryDataViewModel: WalletConnectSingleArbitraryDataViewModel by viewModels()

    private val args: WalletConnectSingleArbitraryDataFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentWalletConnectSingleArbitraryDataBinding::bind)

    private val showArbitraryDataDetailListener = object : WalletConnectSingleArbitraryDataShortDetailView.Listener {
        override fun onShowArbitraryDataDetailClick() {
            listener?.onNavigate(
                WalletConnectSingleArbitraryDataFragmentDirections
                    .actionWalletConnectSingleArbitraryDataFragmentToArbitraryDataRequestDetailFragment(
                        args.arbitraryData.arbitraryData
                    )
            )
        }
    }

    private var listener: ArbitraryDataRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment?.parentFragment as? ArbitraryDataRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        listener?.showButtons()
        binding.customToolbar.configure(toolbarConfiguration)
        initArbitraryDataAbstraction()
    }

    private fun initArbitraryDataAbstraction() {
        val arbitraryDataShortDetail = walletConnectSingleArbitraryDataViewModel.buildArbitraryDataShortDetail(
            args.arbitraryData.arbitraryData
        )
        binding.arbitraryDataMessageTextView.setText(
            walletConnectSingleArbitraryDataViewModel
                .buildArbitraryDataMessage(args.arbitraryData.arbitraryData)
        )
        binding.arbitraryDataShortDetailView.setArbitraryDataShortDetail(
            arbitraryDataShortDetail,
            showArbitraryDataDetailListener
        )
    }
}
