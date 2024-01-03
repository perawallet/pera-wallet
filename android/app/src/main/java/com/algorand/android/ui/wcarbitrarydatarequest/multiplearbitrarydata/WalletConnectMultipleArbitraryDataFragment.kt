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

package com.algorand.android.ui.wcarbitrarydatarequest.multiplearbitrarydata

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentWalletConnectMultipleArbitraryDataBinding
import com.algorand.android.models.ArbitraryDataRequestAction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.ui.wcarbitrarydatarequest.WalletConnectArbitraryDataAdapter
import com.algorand.android.utils.viewbinding.viewBinding

class WalletConnectMultipleArbitraryDataFragment : BaseFragment(
    R.layout.fragment_wallet_connect_multiple_arbitrary_data
) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val toolbarConfiguration = ToolbarConfiguration(titleResId = R.string.unsigned_requests)

    private val binding by viewBinding(FragmentWalletConnectMultipleArbitraryDataBinding::bind)

    private val args: WalletConnectMultipleArbitraryDataFragmentArgs by navArgs()

    private val arbitraryDataAdapterListener = object : WalletConnectArbitraryDataAdapter.Listener {
        override fun onArbitraryDataClick(arbitraryData: WalletConnectArbitraryData) {
            listener?.onNavigate(
                WalletConnectMultipleArbitraryDataFragmentDirections
                    .actionWalletConnectMultipleArbitraryDataFragmentToArbitraryDataRequestDetailFragment(arbitraryData)
            )
        }
    }

    private val arbitraryDataAdapter = WalletConnectArbitraryDataAdapter(arbitraryDataAdapterListener)

    private var listener: ArbitraryDataRequestAction? = null

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment?.parentFragment as? ArbitraryDataRequestAction
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        arbitraryDataAdapter.submitList(args.arbitraryDatas.asList())
    }

    private fun initUi() {
        with(binding) {
            listener?.showButtons()
            customToolbar.configure(toolbarConfiguration)
            arbitraryDataListRecyclerView.adapter = arbitraryDataAdapter
        }
    }
}
