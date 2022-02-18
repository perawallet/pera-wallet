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
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import androidx.paging.PagingData
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.AlgorandTabLayout
import com.algorand.android.databinding.FragmentAddAssetBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.ui.addasset.adapter.AssetSearchAdapter
import com.algorand.android.ui.assetaction.AddAssetActionBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AddAssetFragment : TransactionBaseFragment(R.layout.fragment_add_asset) {

    private var assetSearchAdapter: AssetSearchAdapter? = null

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.add_new_asset,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::onBackPressed,
        showNodeStatus = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAddAssetBinding::bind)

    private val args: AddAssetFragmentArgs by navArgs()

    private val addAssetViewModel: AddAssetViewModel by viewModels()

    private val algorandTabLayoutListener = object : AlgorandTabLayout.Listener {
        override fun onLeftTabSelected() {
            addAssetViewModel.queryType = AssetQueryType.VERIFIED
        }

        override fun onRightTabSelected() {
            addAssetViewModel.queryType = AssetQueryType.ALL
        }
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            binding.loadingProgressBar.isVisible = false
        }

        override fun onSignTransactionLoading() {
            binding.loadingProgressBar.isVisible = true
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            with(signedTransactionDetail) {
                if (this is SignedTransactionDetail.AssetOperation) {
                    addAssetViewModel.sendSignedTransaction(
                        signedTransactionData,
                        assetInformation,
                        accountCacheData.account
                    )
                }
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val sendTransactionObserver = Observer<Event<Resource<Unit>>> {
        it.consume()?.use(
            onSuccess = { nav(AddAssetFragmentDirections.actionAddAssetFragmentToAccountsFragment()) },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.loadingProgressBar.visibility = View.GONE }
        )
    }

    private val assetSearchPaginationCollector: suspend (PagingData<AssetQueryItem>) -> Unit = { pagingData ->
        assetSearchAdapter?.submitData(pagingData)
    }

    // </editor-fold>

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        addAssetViewModel.start(getString(R.string.the_internet_connection))
        initObservers()
        setupToolbar()
        initUi()
    }

    private fun setupToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_info, onClick = ::onInfoClick))
    }

    private fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    private fun setupRecyclerView() {
        if (assetSearchAdapter == null) {
            assetSearchAdapter = AssetSearchAdapter(::onAssetClick)
        }
        binding.assetsRecyclerView.adapter = assetSearchAdapter
        handleLoadState()
    }

    private fun onAssetClick(assetQueryItem: AssetQueryItem) {
        nav(
            AddAssetFragmentDirections.actionAddAssetFragmentToAddAssetActionBottomSheet(
                AssetAction(
                    assetId = assetQueryItem.assetId,
                    asset = AssetInformation(
                        assetId = assetQueryItem.assetId,
                        isVerified = assetQueryItem.isVerified,
                        fullName = assetQueryItem.fullName,
                        shortName = assetQueryItem.shortName
                    )
                )
            )
        )
    }

    private fun initUi() {
        with(binding) {
            algorandTabLayout.setListener(algorandTabLayoutListener)
            searchBar.setOnTextChanged { addAssetViewModel.queryText = it }
            screenStateView.setOnNeutralButtonClickListener { addAssetViewModel.refreshTransactionHistory() }
        }
    }

    private fun initObservers() {
        addAssetViewModel.sendTransactionResultLiveData.observe(viewLifecycleOwner, sendTransactionObserver)
        viewLifecycleOwner.lifecycleScope.launch {
            addAssetViewModel.assetSearchPaginationFlow.collectLatest(assetSearchPaginationCollector)
        }
    }

    private fun onInfoClick() {
        nav(AddAssetFragmentDirections.actionAddAssetFragmentToVerifiedAssetInformationBottomSheet())
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetSearchAdapter?.loadStateFlow?.collectLatest { combinedLoadStates ->
                updateUiWithAssetAdditionLoadStatePreview(
                    addAssetViewModel.createAssetAdditionLoadStatePreview(
                        combinedLoadStates,
                        assetSearchAdapter?.itemCount ?: 0,
                        binding.screenStateView.isVisible
                    )
                )
            }
        }
    }

    private fun updateUiWithAssetAdditionLoadStatePreview(loadStatePreview: AssetAdditionLoadStatePreview) {
        with(binding) {
            loadingProgressBar.isVisible = loadStatePreview.isLoading
            screenStateView.isVisible = loadStatePreview.isScreenStateViewVisible
            assetsRecyclerView.isVisible = loadStatePreview.isAssetListVisible
            loadStatePreview.screenStateViewType?.let { screenStateView.setupUi(it) }
        }
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.addAssetFragment) {
            useSavedStateValue<AssetActionResult>(AddAssetActionBottomSheet.ADD_ASSET_ACTION_RESULT) {
                if (!accountCacheManager.isAccountOwnerOfAsset(args.accountPublicKey, it.asset.assetId)) {
                    val accountCacheData = accountCacheManager.getCacheData(args.accountPublicKey)
                        ?: return@useSavedStateValue
                    sendTransaction(TransactionData.AddAsset(accountCacheData, it.asset))
                } else {
                    context?.showAlertDialog(getString(R.string.error), getString(R.string.you_already_have))
                }
            }
        }
    }
}
