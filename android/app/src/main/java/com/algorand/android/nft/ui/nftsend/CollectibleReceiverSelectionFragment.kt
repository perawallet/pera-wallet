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

package com.algorand.android.nft.ui.nftsend

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionPreview
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionResult
import com.algorand.android.nft.ui.nftsend.CollectibleReceiverSelectionQrScannerFragment.Companion.ACCOUNT_ADDRESS_SCAN_RESULT_KEY
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.setFragmentNavigationResult
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CollectibleReceiverSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.select_account
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override val willCopiedItemBeHandled: Boolean
        get() = true

    private val collectibleReceiverSelectionViewModel by viewModels<CollectibleReceiverSelectionViewModel>()

    private val collectibleReceiverSelectionPreviewCollector: suspend (CollectibleReceiverSelectionPreview?) -> Unit = {
        accountAdapter.submitList(it?.accountSelectionItems)
    }

    override val isSearchBarVisible: Boolean = true

    override val onSearchBarCustomButtonClickListener: () -> Unit = {
        nav(
            CollectibleReceiverSelectionFragmentDirections
                .actionCollectibleReceiverSelectionFragmentToCollectibleReceiverSelectionQrScannerFragment()
        )
    }

    override val onSearchBarTextChangeListener: (String) -> Unit = {
        super.onSearchBarTextChangeListener.invoke(it)
        collectibleReceiverSelectionViewModel.updateSearchingQuery(it)
    }

    override fun onAccountSelected(publicKey: String) {
        setFragmentNavigationResult(
            key = COLLECTIBLE_RECEIVER_ACCOUNT_SELECTION_RESULT_KEY,
            value = CollectibleReceiverSelectionResult.AccountSelectionResult(publicKey)
        )
        navBack()
    }

    override fun onNftDomainSelected(accountAddress: String, nftDomainName: String, nftDomainLogoUrl: String?) {
        setFragmentNavigationResult(
            key = COLLECTIBLE_RECEIVER_NFT_DOMAIN_SELECTION_RESULT_KEY,
            value = CollectibleReceiverSelectionResult.NftDomainSelectionResult(
                accountAddress = accountAddress,
                nftDomainName = nftDomainName,
                nftDomainLogoUrl = nftDomainLogoUrl
            )
        )
        navBack()
    }

    override fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            collectibleReceiverSelectionViewModel.collectibleReceiverSelectionPreviewFlow,
            collectibleReceiverSelectionPreviewCollector
        )
    }

    override fun onCopiedItemHandled(copiedMessage: String?) {
        collectibleReceiverSelectionViewModel.updateCopiedMessage(copiedMessage)
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListeners()
    }

    private fun initSavedStateListeners() {
        startSavedStateListener(R.id.collectibleReceiverSelectionFragment) {
            useSavedStateValue<String>(ACCOUNT_ADDRESS_SCAN_RESULT_KEY) { accountAddress ->
                updateSearchBarText(accountAddress)
            }
        }
    }

    companion object {
        const val COLLECTIBLE_RECEIVER_ACCOUNT_SELECTION_RESULT_KEY = "collectible_receiver_account_selection"
        const val COLLECTIBLE_RECEIVER_NFT_DOMAIN_SELECTION_RESULT_KEY = "collectible_receiver_nft_domain_selection"
    }
}
