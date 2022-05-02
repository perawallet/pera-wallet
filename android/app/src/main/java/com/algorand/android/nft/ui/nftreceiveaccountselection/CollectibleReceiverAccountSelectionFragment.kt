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

package com.algorand.android.nft.ui.nftreceiveaccountselection

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentCollectibleReceiverAccountSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.CollectibleReceiverAccountSelectionPreview
import com.algorand.android.ui.accountselection.AccountSelectionAdapter
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class CollectibleReceiverAccountSelectionFragment :
    DaggerBaseFragment(R.layout.fragment_collectible_receiver_account_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentCollectibleReceiverAccountSelectionBinding::bind)

    private val accountSelectionViewModel by viewModels<CollectibleReceiverAccountSelectionViewModel>()

    private val accountSelectionPreviewCollector: suspend (CollectibleReceiverAccountSelectionPreview) -> Unit = {
        updateUi(it)
    }

    private val accountSelectionAdapterListener = object : AccountSelectionAdapter.Listener {
        override fun onAccountItemClick(publicKey: String) {
            navigateToReceiveCollectibleFragment(publicKey)
        }
    }

    private val accountSelectionAdapter = AccountSelectionAdapter(accountSelectionAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.accountsRecyclerView.adapter = accountSelectionAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            accountSelectionViewModel.collectibleReceiverAccountSelectionPreviewFlow
                .collect(accountSelectionPreviewCollector)
        }
    }

    private fun updateUi(preview: CollectibleReceiverAccountSelectionPreview) {
        with(preview) {
            accountSelectionAdapter.submitList(accountListItems)
            with(binding) {
                progressLayout.loadingProgressBar.isVisible = isLoadingVisible
                screenStateView.isVisible = isScreenStateViewVisible
                screenStateViewType?.run { screenStateView.setupUi(this) }
            }
        }
    }

    private fun navigateToReceiveCollectibleFragment(publicKey: String) {
        nav(
            CollectibleReceiverAccountSelectionFragmentDirections
                .actionCollectibleReceiverAccountSelectionFragmentToReceiveCollectibleFragment(publicKey)
        )
    }
}
