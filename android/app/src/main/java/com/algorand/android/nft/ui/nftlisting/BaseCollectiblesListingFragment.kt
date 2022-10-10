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

package com.algorand.android.nft.ui.nftlisting

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentBaseCollectiblesListingBinding
import com.algorand.android.nft.ui.base.BaseCollectibleListingViewModel
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseCollectiblesListingFragment : DaggerBaseFragment(R.layout.fragment_base_collectibles_listing),
    CollectibleListAdapter.CollectibleListAdapterListener {

    abstract val baseCollectibleListingViewModel: BaseCollectibleListingViewModel

    private lateinit var collectibleListAdapter: CollectibleListAdapter

    protected val binding by viewBinding(FragmentBaseCollectiblesListingBinding::bind)

    protected val collectibleListingPreviewCollector: suspend (CollectiblesListingPreview?) -> Unit = { preview ->
        if (preview != null) initCollectibleListingPreview(preview)
    }

    protected val addCollectibleFloatingActionButtonVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        updateUiWithAddCollectibleFloatingActionButtonVisibility(isVisible)
    }

    abstract fun initCollectiblesListingPreviewCollector()
    abstract fun addItemVisibilityChangeListenerToRecyclerView(recyclerView: RecyclerView)
    abstract fun onAddCollectibleFloatingActionButtonClicked()

    override fun onResume() {
        super.onResume()
        baseCollectibleListingViewModel.startCollectibleListingPreviewFlow()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        baseCollectibleListingViewModel.resetSearchQuery()
        initUi()
        initCollectiblesListingPreviewCollector()
    }

    override fun onReceiveCollectibleItemClick() {
        onReceiveCollectibleClick()
    }

    override fun onSearchQueryUpdated(query: String) {
        baseCollectibleListingViewModel.updateSearchKeyword(query)
    }

    protected open fun initUi() {
        initializeCollectibleListAdapter()
        with(binding) {
            collectiblesRecyclerView.apply {
                adapter = collectibleListAdapter
                layoutManager = CollectibleListGridLayoutManager(context, collectibleListAdapter)
            }
            receiveCollectiblesButton.setOnClickListener { onReceiveCollectibleClick() }
        }
    }

    protected open fun onReceiveCollectibleClick() {
        baseCollectibleListingViewModel.logCollectibleReceiveEvent()
    }

    private fun initCollectibleListingPreview(nftListingPreview: CollectiblesListingPreview) {
        with(nftListingPreview) {
            with(binding) {
                emptyStateScrollView.isVisible = isEmptyStateVisible
                receiveCollectiblesButton.isVisible = isReceiveButtonVisible
                collectiblesRecyclerView.isVisible = !isEmptyStateVisible
                progressBar.isVisible = isLoadingVisible
                collectibleListAdapter.submitList(baseCollectibleListItems)
                clearFiltersButton.apply {
                    setOnClickListener { baseCollectibleListingViewModel.clearFilters() }
                    text = resources.getString(R.string.show_filtered_nfts_formatted, filteredCollectibleCount)
                    isVisible = isClearFilterButtonVisible
                }
                if (isAccountFabVisible) {
                    val paddingBottom = resources.getDimensionPixelSize(R.dimen.safe_padding_for_floating_action_button)
                    binding.emptyStateScrollView.apply {
                        updatePadding(bottom = paddingBottom)
                        clipToPadding = false
                    }
                }
                addCollectibleFloatingActionButton.setOnClickListener { onAddCollectibleFloatingActionButtonClicked() }
            }
        }
    }

    private fun initializeCollectibleListAdapter() {
        if (!::collectibleListAdapter.isInitialized) {
            collectibleListAdapter = CollectibleListAdapter(this)
        }
    }

    protected fun onListItemConfigurationHeaderItemVisibilityChange(isVisible: Boolean) {
        with(binding.baseCollectiblesListingMotionLayout) {
            if (isVisible) {
                transitionToStart()
            } else {
                transitionToEnd()
            }
        }
    }

    private fun updateUiWithAddCollectibleFloatingActionButtonVisibility(isVisible: Boolean?) {
        if (isVisible == true) addItemVisibilityChangeListenerToRecyclerView(binding.collectiblesRecyclerView)
    }
}
