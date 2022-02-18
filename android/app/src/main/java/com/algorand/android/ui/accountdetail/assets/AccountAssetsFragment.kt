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

package com.algorand.android.ui.accountdetail.assets

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountAssetsBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.accountdetail.assets.adapter.AccountAssetsAdapter
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountAssetsFragment : BaseFragment(R.layout.fragment_account_assets) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountAssetsBinding::bind)

    private val accountAssetsViewModel: AccountAssetsViewModel by viewModels()

    private var listener: Listener? = null

    private val accountAssetListener = object : AccountAssetsAdapter.Listener {
        override fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem) {
            listener?.onAssetClick(assetItem)
        }

        override fun onAddNewAssetClick() {
            listener?.onAddAssetClick()
        }

        override fun onSearchViewClick() {
            listener?.onAssetSearchClick()
        }
    }

    private val accountAssetsAdapter = AccountAssetsAdapter(accountAssetListener)

    private val accountAssetsCollector: suspend (List<AccountDetailAssetsItem>) -> Unit = {
        accountAssetsAdapter.submitList(it)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.accountAssetsRecyclerView.adapter = accountAssetsAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            accountAssetsViewModel.accountAssetsFlow.collectLatest(accountAssetsCollector)
        }
    }

    interface Listener {
        fun onAddAssetClick()
        fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem)
        fun onAssetSearchClick()
    }

    companion object {
        const val PUBLIC_KEY = "public_key"
        fun newInstance(publicKey: String): AccountAssetsFragment {
            return AccountAssetsFragment().apply { arguments = Bundle().apply { putString(PUBLIC_KEY, publicKey) } }
        }
    }
}
