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

package com.algorand.android.ui.removeasset

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentRemoveAssetsBinding
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.assetaction.RemoveAssetActionBottomSheet
import com.algorand.android.ui.assetaction.TransferBalanceActionBottomSheet
import com.algorand.android.ui.removeasset.adapter.RemoveAssetAdapter
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger

@AndroidEntryPoint
class RemoveAssetsFragment : TransactionBaseFragment(R.layout.fragment_remove_assets) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack,
        showAccountImage = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val isAssetRemovedObserver = Observer<Event<Resource<Unit>>> { event ->
        event.consume()?.use(
            onSuccess = { navBack() },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.removeAssetsLoadingLayout.root.isVisible = false }
        )
    }

    private val assetListObserver = Observer<List<RemoveAssetItem>> { list ->
        removeAssetAdapter?.submitList(list)
    }

    private var removeAssetAdapter: RemoveAssetAdapter? = null
    private val removeAssetsViewModel: RemoveAssetsViewModel by viewModels()

    private val binding by viewBinding(FragmentRemoveAssetsBinding::bind)

    private val args: RemoveAssetsFragmentArgs by navArgs()

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            binding.removeAssetsLoadingLayout.root.isVisible = false
        }

        override fun onSignTransactionLoading() {
            binding.removeAssetsLoadingLayout.root.isVisible = true
        }

        override fun onSignTransactionFinished(signedTransactionDetail: SignedTransactionDetail) {
            with(signedTransactionDetail) {
                if (this is SignedTransactionDetail.AssetOperation) {
                    removeAssetsViewModel.sendSignedTransaction(
                        signedTransactionData,
                        assetInformation,
                        accountCacheData.account
                    )
                }
            }
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setupRecyclerView()
        removeAssetsViewModel.start(getString(R.string.the_internet_connection))
        initObservers()
    }

    private fun setupToolbar() {
        getAppToolbar()?.apply {
            configure(toolbarConfiguration)
            removeAssetsViewModel.getAccountDetailSummary()?.let {
                changeTitle(it.name)
                setAccountImage(it.accountIcon)
            }
        }
    }

    private fun setupRecyclerView() {
        if (removeAssetAdapter == null) {
            removeAssetAdapter = RemoveAssetAdapter(onRemoveAssetClick = ::onRemoveAssetClick)
        }
        binding.assetsRecyclerView.adapter = removeAssetAdapter
    }

    private fun initObservers() {
        removeAssetsViewModel.removeAssetListLiveData.observe(viewLifecycleOwner, assetListObserver)
        removeAssetsViewModel.removeAssetLiveData.observe(viewLifecycleOwner, isAssetRemovedObserver)
    }

    private fun onRemoveAssetClick(accountAssetData: BaseAccountAssetData.OwnedAssetData) {
        val hasBalanceInAccount = accountAssetData.amount > BigInteger.ZERO
        if (hasBalanceInAccount) {
            navToTransferBalanceActionBottomSheet(accountAssetData)
        } else {
            navToRemoveAssetActionBottomSheet(accountAssetData)
        }
    }

    private fun navToTransferBalanceActionBottomSheet(accountAssetData: BaseAccountAssetData.OwnedAssetData) {
        nav(
            RemoveAssetsFragmentDirections.actionRemoveAssetsFragmentToTransferBalanceActionBottomSheet(
                AssetAction(
                    assetId = accountAssetData.id,
                    asset = AssetInformation.createAssetInformation(accountAssetData)
                )
            )
        )
    }

    private fun navToRemoveAssetActionBottomSheet(accountAssetData: BaseAccountAssetData.OwnedAssetData) {
        nav(
            RemoveAssetsFragmentDirections.actionRemoveAssetsFragmentToRemoveAssetActionBottomSheet(
                AssetAction(
                    assetId = accountAssetData.id,
                    publicKey = args.accountPublicKey,
                    asset = AssetInformation.createAssetInformation(accountAssetData)
                )
            )
        )
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.removeAssetsFragment) {
            useSavedStateValue<AssetActionResult>(RemoveAssetActionBottomSheet.REMOVE_ASSET_ACTION_RESULT) {
                val accountCacheData = accountCacheManager.getCacheData(args.accountPublicKey)
                    ?: return@useSavedStateValue
                val creatorPublicKey = it.asset.creatorPublicKey
                    ?: return@useSavedStateValue
                sendTransaction(
                    TransactionData.RemoveAsset(
                        accountCacheData,
                        it.asset,
                        creatorPublicKey
                    )
                )
            }
            useSavedStateValue<AssetActionResult>(TransferBalanceActionBottomSheet.TRANSFER_ASSET_ACTION_RESULT) {
                val assetTransaction = AssetTransaction(
                    assetId = it.asset.assetId,
                    senderAddress = args.accountPublicKey,
                    amount = BigInteger.ZERO
                )
                nav(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransaction))
            }
        }
    }
}
