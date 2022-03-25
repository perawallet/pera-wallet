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
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentRemoveAssetsBinding
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetActionResult
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.RemoveAssetItem
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.assetaction.RemoveAssetActionBottomSheet
import com.algorand.android.ui.assetaction.TransferBalanceActionBottomSheet
import com.algorand.android.ui.removeasset.adapter.RemoveAssetAdapter
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class RemoveAssetsFragment : TransactionBaseFragment(R.layout.fragment_remove_assets) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack,
        showAccountImage = true
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val removeAssetsViewModel: RemoveAssetsViewModel by viewModels()

    private val binding by viewBinding(FragmentRemoveAssetsBinding::bind)

    private val args: RemoveAssetsFragmentArgs by navArgs()

    private val removeAssetAdapter = RemoveAssetAdapter(onRemoveAssetClick = ::onRemoveAssetClick)

    private val isAssetRemovedObserver = Observer<Event<Resource<Unit>>> { event ->
        event.consume()?.use(
            onSuccess = { navBack() },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.removeAssetsLoadingLayout.root.isVisible = false }
        )
    }

    private val accountAssetListCollector: suspend (value: List<RemoveAssetItem>?) -> Unit = {
        removeAssetAdapter.submitList(it)
    }

    private val accountDetailSummaryCollector: suspend (value: AccountDetailSummary?) -> Unit = {
        if (it != null) updateToolbar(it.name, it.accountIcon)
    }

    override val transactionFragmentListener = object : TransactionFragmentListener {
        override fun onSignTransactionLoadingFinished() {
            binding.removeAssetsLoadingLayout.root.hide()
        }

        override fun onSignTransactionLoading() {
            binding.removeAssetsLoadingLayout.root.show()
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
        setupSearchView()
        setupRecyclerView()
        initObservers()
    }

    private fun setupSearchView() {
        binding.assetSearchView.setOnTextChanged { removeAssetsViewModel.updateSearchingQuery(it) }
    }

    private fun setupToolbar() {
        getAppToolbar()?.configure(toolbarConfiguration)
    }

    private fun updateToolbar(title: String, accountIcon: AccountIcon) {
        getAppToolbar()?.apply {
            changeTitle(title)
            setAccountImage(accountIcon)
        }
    }

    private fun setupRecyclerView() {
        binding.assetsRecyclerView.adapter = removeAssetAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            removeAssetsViewModel.accountAssetListFlow.collectLatest(accountAssetListCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            removeAssetsViewModel.accountDetailSummaryFlow.collectLatest(accountDetailSummaryCollector)
        }

        removeAssetsViewModel.removeAssetLiveData.observe(viewLifecycleOwner, isAssetRemovedObserver)
    }

    private fun onRemoveAssetClick(removeAssetItem: RemoveAssetItem) {
        val hasBalanceInAccount = removeAssetItem.amount > BigInteger.ZERO
        if (hasBalanceInAccount) {
            navToTransferBalanceActionBottomSheet(removeAssetItem)
        } else {
            navToRemoveAssetActionBottomSheet(removeAssetItem)
        }
    }

    private fun navToTransferBalanceActionBottomSheet(removeAssetItem: RemoveAssetItem) {
        nav(
            RemoveAssetsFragmentDirections.actionRemoveAssetsFragmentToTransferBalanceActionBottomSheet(
                AssetAction(
                    assetId = removeAssetItem.id,
                    asset = AssetInformation.createAssetInformation(removeAssetItem)
                )
            )
        )
    }

    private fun navToRemoveAssetActionBottomSheet(removeAssetItem: RemoveAssetItem) {
        nav(
            RemoveAssetsFragmentDirections.actionRemoveAssetsFragmentToRemoveAssetActionBottomSheet(
                AssetAction(
                    assetId = removeAssetItem.id,
                    publicKey = args.accountPublicKey,
                    asset = AssetInformation.createAssetInformation(removeAssetItem)
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
