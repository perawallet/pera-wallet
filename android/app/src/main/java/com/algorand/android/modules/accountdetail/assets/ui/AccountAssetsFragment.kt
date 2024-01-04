@file:SuppressWarnings("TooManyFunctions")
/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.accountdetail.assets.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountAssetsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountAssetsAdapter
import com.algorand.android.modules.accountdetail.assets.ui.domain.AccountAssetsPreviewUseCase
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.utils.ExcludedViewTypesDividerItemDecoration
import com.algorand.android.utils.RecyclerViewPositionVisibilityHandler
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountAssetsFragment : BaseFragment(R.layout.fragment_account_assets) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountAssetsBinding::bind)

    private val accountAssetsViewModel: AccountAssetsViewModel by viewModels()

    private var listener: Listener? = null

    private val recyclerViewPositionVisibilityListener = RecyclerViewPositionVisibilityHandler.Listener { isVisible ->
        with(binding.accountAssetsMotionLayout) {
            if (isVisible) transitionToStart() else transitionToEnd()
        }
    }

    private val recyclerViewPositionVisibilityHandler = RecyclerViewPositionVisibilityHandler(
        position = AccountAssetsPreviewUseCase.QUICK_ACTIONS_INDEX,
        listener = recyclerViewPositionVisibilityListener
    )

    private val accountAssetListener = object : AccountAssetsAdapter.Listener {
        override fun onAssetClick(assetId: Long) {
            listener?.onAssetClick(assetId)
        }

        override fun onAssetLongClick(assetId: Long) {
            listener?.onAssetLongClick(assetId)
        }

        override fun onNFTClick(nftId: Long) {
            listener?.onNFTClick(nftId)
        }

        override fun onNFTLongClick(nftId: Long) {
            listener?.onNFTLongClick(nftId)
        }

        override fun onAddNewAssetClick() {
            accountAssetsViewModel.logAccountAssetsAddAssetEvent()
            listener?.onAddAssetClick()
        }

        override fun onSearchQueryUpdated(query: String) {
            accountAssetsViewModel.updateSearchQuery(query = query)
        }

        override fun onManageAssetsClick() {
            accountAssetsViewModel.logAccountAssetsManageAssetsEvent()
            listener?.onManageAssetsClick()
        }

        override fun onBuySellClick() {
            // TODO refactor with a better name for logging
            accountAssetsViewModel.logAccountAssetsBuyAlgoTapEventTracker()
            listener?.onBuySellClick()
        }

        override fun onSendClick() {
            listener?.onSendClick()
        }

        override fun onSwapClick() {
            listener?.onSwapClick()
        }

        override fun onMoreClick() {
            listener?.onMoreClick()
        }

        override fun onRequiredMinimumBalanceClick() {
            listener?.onMinimumBalanceInfoClick()
        }

        override fun onCopyAddressClick() {
            listener?.onCopyAddressClick()
        }

        override fun onShowAddressClick() {
            listener?.onShowAddressClick()
        }

        override fun onBackupNowClick() {
            listener?.onBackupNowClick()
        }
    }

    private val accountAssetsAdapter = AccountAssetsAdapter(accountAssetListener)

    private val accountAssetsCollector: suspend (List<AccountDetailAssetsItem>?) -> Unit = { accountDetailItemList ->
        accountAssetsAdapter.submitList(accountDetailItemList.orEmpty())
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun onResume() {
        super.onResume()
        // TODO: find a way to update the preview flow only in case of filter option changes
        accountAssetsViewModel.initAccountAssetsFlow()
    }

    private fun initUi() {
        binding.accountAssetsRecyclerView.apply {
            recyclerViewPositionVisibilityHandler.addOnScrollListener(this)
            adapter = accountAssetsAdapter
            addCustomDivider(
                drawableResId = R.drawable.horizontal_divider_80_24dp,
                showLast = false,
                divider = ExcludedViewTypesDividerItemDecoration(AccountDetailAssetsItem.excludedItemFromDivider)
            )
        }
        binding.accountQuickActionsFloatingActionButton.setOnClickListener {
            accountAssetsViewModel.isWatchAccount?.let { isWatchAccount ->
                listener?.onAccountQuickActionsFloatingActionButtonClicked(isWatchAccount)
            }
        }
    }

    private fun initObservers() {
        with(accountAssetsViewModel.accountAssetsFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.accountDetailAssetsItemList },
                collection = accountAssetsCollector
            )
        }
    }

    interface Listener {
        fun onAddAssetClick()
        fun onAssetClick(assetId: Long)
        fun onAssetLongClick(assetId: Long)
        fun onNFTClick(nftId: Long)
        fun onNFTLongClick(nftId: Long)
        fun onBuySellClick()
        fun onSendClick()
        fun onSwapClick()
        fun onMoreClick()
        fun onManageAssetsClick()
        fun onAccountQuickActionsFloatingActionButtonClicked(isWatchAccount: Boolean)
        fun onMinimumBalanceInfoClick()
        fun onCopyAddressClick()
        fun onShowAddressClick()
        fun onBackupNowClick()
    }

    companion object {
        const val ADDRESS_KEY = "address_key"
        fun newInstance(address: String): AccountAssetsFragment {
            return AccountAssetsFragment().apply { arguments = Bundle().apply { putString(ADDRESS_KEY, address) } }
        }
    }
}
