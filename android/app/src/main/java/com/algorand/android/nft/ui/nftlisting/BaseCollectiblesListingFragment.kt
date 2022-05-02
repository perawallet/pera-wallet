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
import androidx.recyclerview.widget.GridLayoutManager
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentBaseCollectiblesListingBinding
import com.algorand.android.nft.ui.base.BaseCollectibleListingViewModel
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.utils.GridSpacingItemDecoration
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseCollectiblesListingFragment :
    DaggerBaseFragment(R.layout.fragment_base_collectibles_listing),
    CollectibleListAdapter.CollectibleListAdapterListener {

    abstract val isTitleVisible: Boolean

    abstract val baseCollectibleListingViewModel: BaseCollectibleListingViewModel

    private lateinit var collectibleListAdapter: CollectibleListAdapter

    protected val binding by viewBinding(FragmentBaseCollectiblesListingBinding::bind)

    protected val collectibleListingPreviewCollector: suspend (CollectiblesListingPreview?) -> Unit = { preview ->
        if (preview != null) initCollectibleListingPreview(preview)
    }

    abstract fun initCollectiblesListingPreviewCollector()
    abstract fun onFilterClick()

    override fun onResume() {
        super.onResume()
        baseCollectibleListingViewModel.startCollectibleListingPreviewFlow()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initCollectiblesListingPreviewCollector()
    }

    protected open fun initUi() {
        initializeCollectibleListAdapter()
        with(binding) {
            collectiblesRecyclerView.apply {
                adapter = collectibleListAdapter
                val itemSpacing = resources.getDimensionPixelSize(R.dimen.spacing_xlarge)
                addItemDecoration(GridSpacingItemDecoration(RECYCLER_SPAN_COUNT, itemSpacing, false))
                layoutManager = GridLayoutManager(context, RECYCLER_SPAN_COUNT)
            }
            receiveCollectiblesButton.setOnClickListener { onReceiveCollectibleClick() }
            filterButton.setOnClickListener { onFilterClick() }
            collectibleSearchView.setOnTextChanged { baseCollectibleListingViewModel.updateSearchKeyword(it) }
        }
    }

    private fun initCollectibleListingPreview(nftListingPreview: CollectiblesListingPreview) {
        with(nftListingPreview) {
            with(binding) {
                emptyStateScrollView.isVisible = isEmptyStateVisible
                receiveCollectiblesButton.isVisible = isReceiveButtonVisible
                titleTextView.isVisible = !isEmptyStateVisible && isTitleVisible
                collectiblesRecyclerView.isVisible = !isEmptyStateVisible
                progressBar.isVisible = isLoadingVisible
                collectibleSearchView.isVisible = !isEmptyStateVisible
                collectibleListAdapter.submitList(baseCollectibleListItems)
                filterButton.apply {
                    isActivated = isFilterActive
                    isVisible = !isEmptyStateVisible
                }
                clearFiltersButton.apply {
                    setOnClickListener { baseCollectibleListingViewModel.clearFilters() }
                    text = resources.getString(R.string.show_filtered_nfts_formatted, filteredCollectibleCount)
                    isVisible = isClearFilterButtonVisible
                }
                collectibleCountTextView.apply {
                    isVisible = !isEmptyStateVisible
                    text = resources.getQuantityString(
                        R.plurals.collectible_count,
                        displayedCollectibleCount,
                        displayedCollectibleCount
                    )
                }
            }
        }
    }

    private fun initializeCollectibleListAdapter() {
        if (!::collectibleListAdapter.isInitialized) {
            collectibleListAdapter = CollectibleListAdapter(this)
        }
    }

    companion object {
        private const val RECYCLER_SPAN_COUNT = 2
    }
}
