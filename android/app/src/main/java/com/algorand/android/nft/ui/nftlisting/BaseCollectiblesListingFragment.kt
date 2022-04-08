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
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseCollectiblesListingFragment :
    DaggerBaseFragment(R.layout.fragment_base_collectibles_listing),
    CollectibleListAdapter.CollectibleListAdapterListener {

    abstract val isTitleVisible: Boolean

    private lateinit var collectibleListAdapter: CollectibleListAdapter

    protected val binding by viewBinding(FragmentBaseCollectiblesListingBinding::bind)

    protected val collectibleListingPreviewCollector: suspend (CollectiblesListingPreview) -> Unit = {
        initCollectibleListingPreview(it)
    }

    abstract fun initCollectiblesListingPreviewCollector()

    abstract fun updateUiWithReceiveButtonVisibility(isVisible: Boolean)

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
                layoutManager = GridLayoutManager(context, RECYCLER_SPAN_COUNT)
            }
            receiveCollectiblesButton.setOnClickListener { onReceiveCollectibleClick() }
        }
    }

    private fun initCollectibleListingPreview(nftListingPreview: CollectiblesListingPreview) {
        with(nftListingPreview) {
            with(binding) {
                emptyStateGroup.isVisible = isEmptyStateVisible
                receiveCollectiblesButton.isVisible = isEmptyStateVisible
                updateUiWithReceiveButtonVisibility(isReceiveButtonVisible)
                titleTextView.isVisible = !isEmptyStateVisible && isTitleVisible
                collectiblesRecyclerView.isVisible = !isEmptyStateVisible
                progressBar.isVisible = isLoadingVisible
                collectibleListAdapter.submitList(baseCollectibleListItems)
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
