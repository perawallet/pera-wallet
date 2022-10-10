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

package com.algorand.android.modules.assets.addition.base.ui

import android.os.Bundle
import android.view.View
import androidx.annotation.LayoutRes
import androidx.core.view.isVisible
import androidx.core.widget.ContentLoadingProgressBar
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.ScreenStateView
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.modules.assets.addition.ui.adapter.AssetSearchAdapter
import com.algorand.android.modules.assets.addition.ui.model.AssetAdditionType
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.hideKeyboard

abstract class BaseAddAssetFragment(@LayoutRes layoutResId: Int) : BaseFragment(layoutResId) {

    abstract fun initUi()
    abstract fun navigateToAssetAdditionBottomSheet(assetAdditionAssetAction: AssetAction)

    abstract val fragmentResId: Int
    abstract val accountPublicKey: String
    abstract val loadingProgressBar: ContentLoadingProgressBar
    abstract val screenStateView: ScreenStateView
    abstract val assetsRecyclerView: RecyclerView
    abstract val assetAdditionType: AssetAdditionType

    abstract val baseAddAssetViewModel: BaseAddAssetViewModel

    private val assetSearchAdapterListener = object : AssetSearchAdapter.AssetSearchAdapterListener {
        override fun onAddAssetClick(assetSearchItem: BaseAssetSearchListItem.AssetListItem) {
            this@BaseAddAssetFragment.onAddAssetClick(assetSearchItem)
        }

        override fun onNavigateToAssetDetail(assetId: Long) {
            onNavigateAssetItemDetail(assetId)
        }

        override fun onNavigateToCollectibleDetail(collectibleId: Long) {
            onNavigateCollectibleDetail(collectibleId)
        }

        override fun onSearchQueryUpdated(query: String) {
            baseAddAssetFragmentListener?.onSearchQueryUpdated(query)
        }
    }

    protected val assetSearchAdapter = AssetSearchAdapter(assetSearchAdapterListener)

    private val assetSearchPaginationCollector: suspend (PagingData<BaseAssetSearchListItem>) -> Unit = { pagingData ->
        assetSearchAdapter.submitData(pagingData)
    }

    private val loadStateFlowCollector: suspend (CombinedLoadStates) -> Unit = { combinedLoadStates ->
        updateUiWithAssetAdditionLoadStatePreview(
            createAssetAdditionLoadStatePreview(
                combinedLoadStates
            )
        )
    }

    protected open val baseAddAssetFragmentListener: BaseAddAssetFragmentListener? = null

    open fun onNavigateAssetItemDetail(assetId: Long) {}
    open fun onNavigateCollectibleDetail(collectibleId: Long) {}

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        handleLoadState()
    }

    protected fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            baseAddAssetViewModel.assetSearchPaginationFlow,
            assetSearchPaginationCollector
        )
    }

    protected fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    private fun handleLoadState() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            assetSearchAdapter.loadStateFlow,
            loadStateFlowCollector
        )
    }

    private fun onAddAssetClick(assetSearchItem: BaseAssetSearchListItem.AssetListItem) {
        val assetAdditionAssetAction = AssetAction(
            assetId = assetSearchItem.assetId,
            asset = AssetInformation(
                assetId = assetSearchItem.assetId,
                fullName = assetSearchItem.fullName.getName(resources),
                shortName = assetSearchItem.shortName.getName(resources),
                verificationTier = (assetSearchItem as? BaseAssetSearchListItem.AssetListItem.AssetSearchItem)
                    ?.verificationTierConfiguration?.toVerificationTier()
            ),
            publicKey = accountPublicKey
        )
        navigateToAssetAdditionBottomSheet(assetAdditionAssetAction)
    }

    private fun createAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
    ): AssetAdditionLoadStatePreview {
        return baseAddAssetViewModel.createAssetAdditionLoadStatePreview(
            combinedLoadStates = combinedLoadStates,
            itemCount = assetSearchAdapter.itemCount,
            isLastStateError = screenStateView.isVisible,
            assetAdditionType = assetAdditionType
        )
    }

    private fun updateUiWithAssetAdditionLoadStatePreview(loadStatePreview: AssetAdditionLoadStatePreview) {
        loadingProgressBar.isVisible = loadStatePreview.isLoading
        screenStateView.isVisible = loadStatePreview.isScreenStateViewVisible
        assetsRecyclerView.isVisible = loadStatePreview.isAssetListVisible
        loadStatePreview.screenStateViewType?.let { screenStateView.setupUi(it) }
        loadStatePreview.onRetryEvent?.consume()?.run { assetSearchAdapter.retry() }
    }

    fun interface BaseAddAssetFragmentListener {
        fun onSearchQueryUpdated(query: String)
    }
}
