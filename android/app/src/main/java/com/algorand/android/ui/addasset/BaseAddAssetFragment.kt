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

package com.algorand.android.ui.addasset

import android.os.Bundle
import android.view.View
import androidx.annotation.LayoutRes
import androidx.core.view.isVisible
import androidx.core.widget.ContentLoadingProgressBar
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.ScreenStateView
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.ui.addasset.adapter.AssetSearchAdapter
import com.algorand.android.ui.assetaction.AddAssetActionBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

abstract class BaseAddAssetFragment(@LayoutRes layoutResId: Int) : TransactionBaseFragment(layoutResId) {

    abstract fun initUi()
    abstract fun onSendTransactionSuccess()
    abstract fun navigateToAssetAdditionBottomSheet(assetAdditionAssetAction: AssetAction)
    abstract fun onAssetAlreadyOwned()

    abstract val fragmentResId: Int
    abstract val accountPublicKey: String
    abstract val loadingProgressBar: ContentLoadingProgressBar
    abstract val screenStateView: ScreenStateView
    abstract val assetsRecyclerView: RecyclerView
    abstract val assetAdditionType: AssetAdditionType

    abstract val baseAddAssetViewModel: BaseAddAssetViewModel

    protected val assetSearchAdapter = AssetSearchAdapter(::onCollectibleSelected)

    private val assetSearchPaginationCollector: suspend (PagingData<BaseAssetSearchListItem>) -> Unit = { pagingData ->
        assetSearchAdapter.submitData(pagingData)
    }

    private val sendTransactionObserver = Observer<Event<Resource<Unit>>> {
        it.consume()?.use(
            onSuccess = { onSendTransactionSuccess() },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { loadingProgressBar.hide() }
        )
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            loadingProgressBar.hide()
        }

        override fun onSignTransactionLoading() {
            loadingProgressBar.show()
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            with(signedTransactionDetail) {
                if (this is SignedTransactionDetail.AssetOperation) {
                    baseAddAssetViewModel.sendSignedTransaction(
                        signedTransactionData,
                        assetInformation,
                        accountCacheData.account
                    )
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        handleLoadState()
    }

    protected fun initObservers() {
        baseAddAssetViewModel.sendTransactionResultLiveData.observe(viewLifecycleOwner, sendTransactionObserver)
        viewLifecycleOwner.lifecycleScope.launch {
            baseAddAssetViewModel.assetSearchPaginationFlow.collectLatest(assetSearchPaginationCollector)
        }
    }

    protected fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetSearchAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                updateUiWithAssetAdditionLoadStatePreview(createAssetAdditionLoadStatePreview(combinedLoadStates))
            }
        }
    }

    private fun onCollectibleSelected(assetSearchItem: BaseAssetSearchListItem) {
        val assetAdditionAssetAction = AssetAction(
            assetId = assetSearchItem.assetId,
            asset = AssetInformation(
                assetId = assetSearchItem.assetId,
                isVerified = assetSearchItem.isVerified,
                fullName = assetSearchItem.fullName.getName(resources),
                shortName = assetSearchItem.shortName.getName(resources)
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
    }

    private fun initSavedStateListener() {
        startSavedStateListener(fragmentResId) {
            useSavedStateValue<AssetActionResult>(AddAssetActionBottomSheet.ADD_ASSET_ACTION_RESULT) {
                handleAssetActionBottomSheetResult(it, accountPublicKey)
            }
        }
    }

    private fun handleAssetActionBottomSheetResult(result: AssetActionResult, publicKey: String) {
        if (!baseAddAssetViewModel.isAssetOwnedByAccount(publicKey, result.asset.assetId)) {
            val accountCacheData = accountCacheManager.getCacheData(publicKey) ?: return
            sendTransaction(TransactionData.AddAsset(accountCacheData, result.asset))
        } else {
            onAssetAlreadyOwned()
        }
    }
}
