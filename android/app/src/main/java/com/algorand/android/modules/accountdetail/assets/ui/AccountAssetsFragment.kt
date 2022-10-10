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
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.modules.accountdetail.assets.ui.adapter.AccountAssetsAdapter
import com.algorand.android.usecase.AccountAssetsPreviewUseCase.Companion.QUICK_ACTIONS_INDEX
import com.algorand.android.utils.AccountAssetsDividerItemDecoration
import com.algorand.android.utils.addCustomDivider
import com.algorand.android.utils.addItemVisibilityChangeListener
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AccountAssetsFragment : BaseFragment(R.layout.fragment_account_assets) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountAssetsBinding::bind)

    private val accountAssetsViewModel: AccountAssetsViewModel by viewModels()

    private var listener: Listener? = null

    private val accountAssetListener = object : AccountAssetsAdapter.Listener {
        override fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem) {
            listener?.onAssetClick(assetItem)
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

        override fun onBuyAlgoClick() {
            accountAssetsViewModel.logAccountAssetsBuyAlgoTapEventTracker()
            listener?.onBuyAlgoClick()
        }

        override fun onSendClick() {
            listener?.onSendClick()
        }

        override fun onAddressClick() {
            listener?.onAddressClick()
        }

        override fun onMoreClick() {
            listener?.onMoreClick()
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
        accountAssetsViewModel.resetSearchQuery()
        initUi()
        initObservers()
    }

    override fun onResume() {
        super.onResume()
        accountAssetsViewModel.initAccountAssetsFlow()
    }

    private fun initUi() {
        binding.accountAssetsRecyclerView.adapter = accountAssetsAdapter
        binding.accountAssetsRecyclerView.addCustomDivider(
            drawableResId = R.drawable.horizontal_divider_80_24dp,
            showLast = false,
            divider = AccountAssetsDividerItemDecoration()
        )
        if (accountAssetsViewModel.canAccountSignTransactions()) {
            binding.accountQuickActionsFloatingActionButton.setOnClickListener {
                listener?.onAccountQuickActionsFloatingActionButtonClicked()
            }
            binding.accountAssetsRecyclerView.addItemVisibilityChangeListener(QUICK_ACTIONS_INDEX) { isVisible ->
                with(binding.accountAssetsMotionLayout) {
                    if (isVisible) transitionToStart() else transitionToEnd()
                }
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            accountAssetsViewModel.accountAssetsFlow,
            accountAssetsCollector
        )
    }

    interface Listener {
        fun onAddAssetClick()
        fun onAssetClick(assetItem: AccountDetailAssetsItem.BaseAssetItem)
        fun onBuyAlgoClick()
        fun onSendClick()
        fun onAddressClick()
        fun onMoreClick()
        fun onManageAssetsClick()
        fun onAccountQuickActionsFloatingActionButtonClicked()
    }

    companion object {
        const val ADDRESS_KEY = "address_key"
        fun newInstance(address: String): AccountAssetsFragment {
            return AccountAssetsFragment().apply { arguments = Bundle().apply { putString(ADDRESS_KEY, address) } }
        }
    }
}
