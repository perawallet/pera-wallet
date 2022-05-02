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

import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.base.BaseCollectibleListingViewModel
import com.algorand.android.nft.ui.nftlisting.BaseCollectiblesListingFragment
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class CollectiblesFragment : BaseCollectiblesListingFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(backgroundColor = R.color.primary_background)

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true
    )

    override val isTitleVisible: Boolean
        get() = true
    private val collectiblesViewModel by viewModels<CollectiblesViewModel>()

    override val baseCollectibleListingViewModel: BaseCollectibleListingViewModel
        get() = collectiblesViewModel

    private val toolbarReceiveButtonVisibilityCollector: suspend (Boolean?) -> Unit = { isReceiveButtonVisible ->
        updateUiWithReceiveButtonVisibility(isReceiveButtonVisible)
    }

    override fun initUi() {
        super.initUi()
        val receiveCollectibleButton = IconButton(R.drawable.ic_plus, onClick = ::onReceiveCollectibleClick)
        getAppToolbar()?.addButtonToEnd(receiveCollectibleButton)
    }

    override fun onVideoItemClick(collectibleAssetId: Long, publicKey: String) {
        nav(
            CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleDetailFragment(
                collectibleAssetId = collectibleAssetId,
                publicKey = publicKey
            )
        )
    }

    override fun onImageItemClick(collectibleAssetId: Long, publicKey: String) {
        nav(
            CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleDetailFragment(
                collectibleAssetId = collectibleAssetId,
                publicKey = publicKey
            )
        )
    }

    override fun onSoundItemClick(collectibleAssetId: Long, publicKey: String) {
        // TODO "Not yet implemented"
    }

    override fun onGifItemClick(collectibleAssetId: Long, publicKey: String) {
        // TODO "Not yet implemented"
    }

    override fun onNotSupportedItemClick(collectibleAssetId: Long, publicKey: String) {
        // TODO "Not yet implemented"
    }

    override fun onMixedItemClick(collectibleAssetId: Long, publicKey: String) {
        nav(
            CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleDetailFragment(
                collectibleAssetId = collectibleAssetId,
                publicKey = publicKey
            )
        )
    }

    override fun onReceiveCollectibleClick() {
        nav(CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleReceiverAccountSelectionFragment())
    }

    override fun onFilterClick() {
        nav(CollectiblesFragmentDirections.actionCollectiblesFragmentToCollectibleFiltersFragment())
    }

    override fun initCollectiblesListingPreviewCollector() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            with(collectiblesViewModel.collectiblesListingPreviewFlow) {
                collect(collectibleListingPreviewCollector)
                map { it?.isReceiveButtonVisible }.collect(toolbarReceiveButtonVisibilityCollector)
            }
        }
    }

    private fun updateUiWithReceiveButtonVisibility(isVisible: Boolean?) {
        if (isVisible == true) {
            getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_plus, onClick = ::onReceiveCollectibleClick))
        }
    }
}
