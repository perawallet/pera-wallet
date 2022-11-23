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

package com.algorand.android.modules.swap.assetselection.base

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.databinding.FragmentSwapAssetSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.swap.assetselection.base.SwapAssetSelectionAdapter.SwapAssetSelectionAdapterListener
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapAssetSelectionItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

abstract class BaseSwapAssetSelectionFragment : BaseFragment(R.layout.fragment_swap_asset_selection) {

    abstract fun onAssetSelected(assetItem: SwapAssetSelectionItem)
    abstract fun setToolbarTitle(toolbar: CustomToolbar?)

    abstract val baseAssetSelectionViewModel: BaseSwapAssetSelectionViewModel

    private val binding by viewBinding(FragmentSwapAssetSelectionBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val swapAssetSelectionAdapterListener = object : SwapAssetSelectionAdapterListener {
        override fun onAssetSelected(item: SwapAssetSelectionItem) {
            this@BaseSwapAssetSelectionFragment.onAssetSelected(item)
        }
    }

    private val swapAssetSelectionAdapter = SwapAssetSelectionAdapter(swapAssetSelectionAdapterListener)

    private val assetSelectionItemListCollector: suspend (List<SwapAssetSelectionItem>?) -> Unit = {
        swapAssetSelectionAdapter.submitList(it.orEmpty())
    }

    private val isLoadingStateCollector: suspend (Boolean?) -> Unit = { isLoading ->
        binding.progressBar.root.isVisible = isLoading == true
    }

    private val screenStateCollector: suspend (ScreenState?) -> Unit = { screenState ->
        binding.screenStateView.apply {
            isVisible = screenState != null
            setupUi(screenState ?: return@apply)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setToolbarTitle(getAppToolbar())
        initObservers()
        initUi()
    }

    private fun initUi() {
        with(binding) {
            swapAssetSelectionRecyclerView.adapter = swapAssetSelectionAdapter
            searchView.setOnTextChanged { query ->
                baseAssetSelectionViewModel.updateSearchQuery(query)
            }
        }
    }

    protected open fun initObservers() {
        with(baseAssetSelectionViewModel.swapAssetSelectionPreviewFlow) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                map { it?.swapAssetSelectionItemList }.distinctUntilChanged(),
                assetSelectionItemListCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                map { it?.isLoading }.distinctUntilChanged(),
                isLoadingStateCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                map { it?.screenState }.distinctUntilChanged(),
                screenStateCollector
            )
        }
    }
}
