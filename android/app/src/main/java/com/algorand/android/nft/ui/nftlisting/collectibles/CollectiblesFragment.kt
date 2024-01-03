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

package com.algorand.android.nft.ui.nftlisting.collectibles

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.domain.usecase.CollectiblesListingPreviewUseCase.Companion.COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX
import com.algorand.android.nft.ui.nftlisting.BaseCollectiblesListingFragment
import com.algorand.android.utils.addItemVisibilityChangeListener
import com.algorand.android.utils.delegation.bottomnavfragment.BottomNavBarFragmentDelegation
import com.algorand.android.utils.delegation.bottomnavfragment.BottomNavBarFragmentDelegationImpl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class CollectiblesFragment : BaseCollectiblesListingFragment(),
    BottomNavBarFragmentDelegation by BottomNavBarFragmentDelegationImpl() {

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.primary_background)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true
    )

    override val baseCollectibleListingViewModel: CollectiblesViewModel by viewModels()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerBottomNavBarFragmentDelegation(this)
    }

    override fun onOwnedNFTItemClick(collectibleAssetId: Long, publicKey: String) {
        nav(
            CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleDetailFragment(
                collectibleAssetId = collectibleAssetId,
                publicKey = publicKey
            )
        )
    }

    override fun onReceiveCollectibleClick() {
        super.onReceiveCollectibleClick()
        nav(CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleReceiverAccountSelectionFragment())
    }

    override fun onManageCollectiblesClick() {
        nav(CollectiblesFragmentDirections.actionCollectiblesFragmentToManageCollectiblesBottomSheet())
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
            COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX
        ) { isVisible -> onListItemConfigurationHeaderItemVisibilityChange(isVisible) }
    }

    override fun onAddCollectibleFloatingActionButtonClicked() {
        nav(CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleReceiverAccountSelectionFragment())
    }
}
