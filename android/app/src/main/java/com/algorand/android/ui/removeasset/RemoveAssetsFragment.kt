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

package com.algorand.android.ui.removeasset

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.asLiveData
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.databinding.FragmentRemoveAssetsBinding
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.TransactionData
import com.algorand.android.ui.common.AssetActionBottomSheet
import com.algorand.android.ui.common.listhelper.AccountAdapter
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.removeasset.RemoveAssetsFragmentDirections.Companion.actionRemoveAssetsFragmentToSendInfoFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.math.BigInteger
import javax.inject.Inject

@AndroidEntryPoint
class RemoveAssetsFragment : TransactionBaseFragment(R.layout.fragment_remove_assets),
    AssetActionBottomSheet.AddAssetConfirmationPopupListener {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.remove_assets,
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    @Inject
    lateinit var accountManager: AccountManager

    // <editor-fold defaultstate="collapsed" desc="Observers">

    private val isAssetRemovedObserver = Observer<Event<Resource<Unit>>> { event ->
        event.consume()?.use(
            onSuccess = { navBack() },
            onFailed = { error -> showGlobalError(error.parse(requireContext())) },
            onLoadingFinished = { binding.removeAssetsLoadingLayout.root.isVisible = false }
        )
    }

    private val assetListObserver = Observer<List<BaseAccountListItem>> { list ->
        accountAdapter?.submitList(list)
    }

    private val keyAssetsListObserver = Observer<Map<String, AccountCacheData>> { keyAssetsList ->
        removeAssetsViewModel.constructList(keyAssetsList, args.accountPublicKey)
    }
    // </editor-fold>

    private var accountAdapter: AccountAdapter? = null
    private val removeAssetsViewModel: RemoveAssetsViewModel by viewModels()

    private val binding by viewBinding(FragmentRemoveAssetsBinding::bind)

    private val args: RemoveAssetsFragmentArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupRecyclerView()
        removeAssetsViewModel.start(getString(R.string.the_internet_connection))
        initObservers()
    }

    private fun setupRecyclerView() {
        if (accountAdapter == null) {
            accountAdapter = AccountAdapter(onRemoveAssetClick = ::onRemoveAssetClick)

            binding.assetsRecyclerView.adapter = accountAdapter
        }
    }

    private fun initObservers() {
        with(accountCacheManager) {
            accountCacheMap.asLiveData().observe(viewLifecycleOwner, keyAssetsListObserver)
        }

        removeAssetsViewModel.removeAssetListLiveData.observe(viewLifecycleOwner, assetListObserver)

        removeAssetsViewModel.removeAssetLiveData.observe(viewLifecycleOwner, isAssetRemovedObserver)
    }

    private fun onRemoveAssetClick(publicKey: String, assetInformation: AssetInformation) {
        if (accountCacheManager.getAssetInformation(publicKey, assetInformation.assetId)?.amount == BigInteger.ZERO) {
            AssetActionBottomSheet.show(
                childFragmentManager,
                assetInformation.assetId,
                AssetActionBottomSheet.Type.REMOVE_ASSET,
                publicKey,
                asset = assetInformation
            )
        } else {
            AssetActionBottomSheet.show(
                childFragmentManager,
                assetInformation.assetId,
                AssetActionBottomSheet.Type.TRANSFER_BALANCE,
                asset = assetInformation
            )
        }
    }

    override fun onPopupConfirmation(
        type: AssetActionBottomSheet.Type,
        popupAsset: AssetInformation,
        publicKey: String?
    ) {
        when (type) {
            AssetActionBottomSheet.Type.TRANSFER_BALANCE -> {
                // Move to send info with maximum amount.
                nav(
                    actionRemoveAssetsFragmentToSendInfoFragment(
                        assetInformation = popupAsset,
                        fromAccountAddress = args.accountPublicKey,
                        amount = popupAsset.amount ?: BigInteger.ZERO
                    )
                )
            }
            AssetActionBottomSheet.Type.REMOVE_ASSET -> {
                val accountCacheData = accountCacheManager.getCacheData(args.accountPublicKey) ?: return
                val creatorPublicKey = popupAsset.creatorPublicKey ?: return
                sendTransaction(TransactionData.RemoveAsset(accountCacheData, popupAsset, creatorPublicKey))
            }
        }
    }

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
}
