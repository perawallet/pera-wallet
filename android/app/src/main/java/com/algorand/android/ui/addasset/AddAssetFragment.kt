/*
 * Copyright 2019 Algorand, Inc.
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
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.core.view.isVisible
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import androidx.paging.LoadState
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.customviews.HorizontalSwitch
import com.algorand.android.databinding.FragmentAddAssetBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetQueryItem
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.addasset.AddAssetFragmentDirections.Companion.actionAddAssetFragmentToVerifiedAssetInformationBottomSheet
import com.algorand.android.ui.common.AssetActionBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.addDivider
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.showAlertDialog
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AddAssetFragment : TransactionBaseFragment(R.layout.fragment_add_asset),
    AssetActionBottomSheet.AddAssetConfirmationPopupListener {

    @Inject
    lateinit var accountManager: AccountManager

    private var assetSearchAdapter: AssetSearchAdapter? = null

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.add_new_asset,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::onBackPressed,
        showNodeStatus = true
    )

    private val binding by viewBinding(FragmentAddAssetBinding::bind)

    private val args: AddAssetFragmentArgs by navArgs()

    private val addAssetViewModel: AddAssetViewModel by viewModels()

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val sendTransactionObserver = Observer<Event<Resource<Unit>>> {
        it.consume()?.use(
            onSuccess = { nav(AddAssetFragmentDirections.actionAddAssetFragmentToAccountsFragment()) },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.loadingProgressBar.visibility = View.GONE }
        )
    }

    // </editor-fold>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        addAssetViewModel.start(getString(R.string.the_internet_connection))
        initObservers()
        initEditTextWatcher()
        initSwitchWatcher()
        setupToolbar()
    }

    private fun setupToolbar() {
        getAppToolbar()?.apply {
            val infoButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

            infoButton.apply {
                setImageResource(R.drawable.ic_info)
                setOnClickListener { onInfoClick() }
                addViewToEndSide(this)
            }
        }
    }

    private fun initSwitchWatcher() {
        binding.verifiedSwitch.setup(
            listener = object : HorizontalSwitch.Listener {
                override fun onSwitch(isLeftSelected: Boolean) {
                    addAssetViewModel.queryType = if (isLeftSelected) AssetQueryType.VERIFIED else AssetQueryType.ALL
                }
            },
            leftSwitchTextResId = R.string.verified_with_icon,
            rightSwitchTextResId = R.string.all
        )
        if (addAssetViewModel.queryType == AssetQueryType.ALL) {
            binding.verifiedSwitch.enableSwitch(isLeftSelected = false, invokeListener = false)
        }
    }

    private fun onBackPressed() {
        view?.hideKeyboard()
        navBack()
    }

    private fun setupRecyclerView() {
        if (assetSearchAdapter == null) {
            assetSearchAdapter = AssetSearchAdapter(::onAssetClick)
        }

        binding.assetsRecyclerView.apply {
            addDivider(R.drawable.horizontal_divider_20dp)
            adapter = assetSearchAdapter
        }

        handleLoadState()
    }

    private fun onAssetClick(assetQueryItem: AssetQueryItem) {
        AssetActionBottomSheet.show(
            childFragmentManager,
            assetQueryItem.assetId,
            AssetActionBottomSheet.Type.ADD_ASSET,
            asset = AssetInformation(
                assetId = assetQueryItem.assetId,
                isVerified = assetQueryItem.isVerified ?: false,
                fullName = assetQueryItem.fullName,
                shortName = assetQueryItem.shortName
            )
        )
    }

    override fun onPopupConfirmation(
        type: AssetActionBottomSheet.Type,
        popupAsset: AssetInformation,
        publicKey: String?
    ) {
        if (type == AssetActionBottomSheet.Type.ADD_ASSET) {
            if (accountCacheManager.isAccountOwnerOfAsset(args.accountPublicKey, popupAsset.assetId).not()) {
                val accountCacheData = accountCacheManager.getCacheData(args.accountPublicKey) ?: return
                sendTransaction(TransactionData.AddAsset(accountCacheData, popupAsset))
            } else {
                context?.showAlertDialog(getString(R.string.error), getString(R.string.you_already_have))
            }
        }
    }

    private fun initEditTextWatcher() {
        binding.searchEditText.doAfterTextChanged { addAssetViewModel.queryText = it.toString() }
    }

    private fun initObservers() {
        addAssetViewModel.sendTransactionResultLiveData.observe(viewLifecycleOwner, sendTransactionObserver)
        lifecycleScope.launch {
            addAssetViewModel.assetSearchPaginationFlow.collectLatest { pagingData ->
                assetSearchAdapter?.submitData(pagingData)
            }
        }
    }

    private fun onInfoClick() {
        nav(actionAddAssetFragmentToVerifiedAssetInformationBottomSheet())
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

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            assetSearchAdapter?.loadStateFlow?.collectLatest { combinedLoadStates ->
                binding.loadingProgressBar.isVisible = combinedLoadStates.refresh is LoadState.Loading
                if (combinedLoadStates.refresh is LoadState.Error) {
                    showSnackbar(getString(R.string.an_error_more), binding.addAssetRootLayout)
                }
                binding.emptyGroup.isVisible =
                    combinedLoadStates.refresh is LoadState.NotLoading && assetSearchAdapter?.itemCount == 0
            }
        }
    }
}
