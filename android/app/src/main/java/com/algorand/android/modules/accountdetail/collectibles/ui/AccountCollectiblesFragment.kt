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

package com.algorand.android.modules.accountdetail.collectibles.ui

import android.content.Context
import android.os.Bundle
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.nft.domain.usecase.AccountCollectiblesListingPreviewUseCase.Companion.ACCOUNT_COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX
import com.algorand.android.nft.ui.nftlisting.BaseCollectiblesListingFragment
import com.algorand.android.utils.addItemVisibilityChangeListener
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountCollectiblesFragment : BaseCollectiblesListingFragment() {

    override val fragmentConfiguration = FragmentConfiguration()

    override val baseCollectibleListingViewModel: AccountCollectiblesViewModel by viewModels()

    private var listener: Listener? = null

    override fun onOwnedNFTItemClick(collectibleAssetId: Long, publicKey: String) {
        listener?.onVideoItemClick(collectibleAssetId)
    }

    override fun onReceiveCollectibleClick() {
        super.onReceiveCollectibleClick()
        listener?.onReceiveCollectibleClick()
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    override fun initCollectiblesListingPreviewCollector() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            baseCollectibleListingViewModel.collectiblesListingPreviewFlow,
            collectibleListingPreviewCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = baseCollectibleListingViewModel.collectiblesListingPreviewFlow
                .map { it?.isAddCollectibleFloatingActionButtonVisible }
                .distinctUntilChanged(),
            collection = addCollectibleFloatingActionButtonVisibilityCollector,
            state = Lifecycle.State.STARTED
        )
    }

    override fun addItemVisibilityChangeListenerToRecyclerView(recyclerView: RecyclerView) {
        recyclerView.addItemVisibilityChangeListener(
            ACCOUNT_COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX
        ) { isVisible -> onListItemConfigurationHeaderItemVisibilityChange(isVisible) }
    }

    override fun onAddCollectibleFloatingActionButtonClicked() {
        listener?.onReceiveCollectibleClick()
    }

    override fun onManageCollectiblesClick() {
        listener?.onManageCollectiblesClick()
    }

    interface Listener {
        fun onImageItemClick(nftAssetId: Long)
        fun onVideoItemClick(nftAssetId: Long)
        fun onSoundItemClick(nftAssetId: Long)
        fun onGifItemClick(nftAssetId: Long)
        fun onNotSupportedItemClick(nftAssetId: Long)
        fun onMixedItemClick(nftAssetId: Long)
        fun onReceiveCollectibleClick()
        fun onManageCollectiblesClick()
    }

    companion object {
        const val PUBLIC_KEY = "public_key"
        fun newInstance(publicKey: String): AccountCollectiblesFragment {
            return AccountCollectiblesFragment().apply {
                arguments = Bundle().apply { putString(PUBLIC_KEY, publicKey) }
            }
        }
    }
}
