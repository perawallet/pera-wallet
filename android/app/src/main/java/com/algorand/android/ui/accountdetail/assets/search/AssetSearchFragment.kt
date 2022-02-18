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

package com.algorand.android.ui.accountdetail.assets.search

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetSearchBinding
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountdetail.assets.adapter.AccountAssetsAdapter
import com.algorand.android.utils.Resource
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetSearchFragment : BaseFragment(R.layout.fragment_asset_search) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    override val fragmentConfiguration = FragmentConfiguration()

    private val assetSearchViewModel: AssetSearchViewModel by viewModels()

    private val binding by viewBinding(FragmentAssetSearchBinding::bind)

    private val accountAssetsCollector: suspend (value: Resource<List<AccountDetailAssetsItem>>) -> Unit = {
        it.use(
            onSuccess = {
                assetSearchAdapter.submitList(it)
                binding.screenStateView.isVisible = it.isEmpty()
            },
            onFailed = { showGlobalError(it.parse(binding.root.context)) }
        )
    }

    private val assetSearchAdapterListener = object : AccountAssetsAdapter.Listener {
        override fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem) {
            nav(
                AssetSearchFragmentDirections.actionAssetSearchFragmentToAssetDetailFragment(
                    assetItem.id,
                    assetSearchViewModel.publicKey
                )
            )
        }
    }

    private val assetSearchAdapter = AccountAssetsAdapter(assetSearchAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            customToolbar.configure(toolbarConfiguration)
            assetsRecyclerView.adapter = assetSearchAdapter
            assetSearchView.setFocusAndOpenKeyboard()
            assetSearchView.setOnTextChanged { assetSearchViewModel.onFilterListByQuery(it) }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetSearchViewModel.accountAssetFlow.collectLatest(accountAssetsCollector)
        }
    }

    override fun onPause() {
        view?.hideKeyboard()
        super.onPause()
    }
}
