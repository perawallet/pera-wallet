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

package com.algorand.android.nft.ui.nftfilters

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentCollectibleFiltersBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.nft.ui.nftfilters.model.CollectibleFiltersPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class CollectibleFiltersFragment : BaseFragment(R.layout.fragment_collectible_filters) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.filter_nfts,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    private val binding by viewBinding(FragmentCollectibleFiltersBinding::bind)

    private val collectibleFiltersViewModel by viewModels<CollectibleFiltersViewModel>()

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val collectibleFiltersPreviewCollector: suspend (CollectibleFiltersPreview?) -> Unit = { preview ->
        if (preview != null) initPreview(preview)
    }

    private val onNavigateBackEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run { navBack() }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        initUi()
        initObservers()
    }

    private fun initObservers() {
        with(collectibleFiltersViewModel) {
            collectOnLifecycle(
                flow = collectibleFiltersPreviewFlow,
                collection = collectibleFiltersPreviewCollector
            )
            collectLatestOnLifecycle(
                flow = collectibleFiltersPreviewFlow.map { it?.onNavigateBackEvent },
                collection = onNavigateBackEventCollector
            )
        }
    }

    private fun configureToolbar() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.done, onClick = ::saveChanges))
    }

    private fun saveChanges() {
        collectibleFiltersViewModel.saveChanges()
    }

    private fun initUi() {
        with(binding) {
            with(collectibleFiltersViewModel) {
                displayOptedInNFTsSwitch.setOnCheckedChangeListener { _, isChecked ->
                    onDisplayOptedInNFTsSwitchChanged(isChecked)
                }
                displayWatchAccountNFTsSwitch.setOnCheckedChangeListener { _, isChecked ->
                    onDisplayWatchAccountNFTsSwitchChanged(isChecked)
                }
            }
        }
    }

    private fun initPreview(collectibleFiltersPreview: CollectibleFiltersPreview) {
        with(binding) {
            with(collectibleFiltersPreview) {
                displayOptedInNFTsSwitch.isChecked = displayOptedInNFTsPreference
                displayWatchAccountNFTsSwitch.isChecked = displayWatchAccountNFTsPreference
            }
        }
    }
}
