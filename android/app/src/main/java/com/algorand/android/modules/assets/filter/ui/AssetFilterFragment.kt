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

package com.algorand.android.modules.assets.filter.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetFilterBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.filter.ui.model.AssetFilterPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.setFragmentNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AssetFilterFragment : BaseFragment(R.layout.fragment_asset_filter) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.filter_assets
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val assetFilterViewModel by viewModels<AssetFilterViewModel>()

    private val binding by viewBinding(FragmentAssetFilterBinding::bind)

    private val assetFilterPreviewCollector: suspend (AssetFilterPreview?) -> Unit = { preview ->
        if (preview != null) initPreview(preview)
    }

    private val onNavigateBackEventCollector: suspend (Event<Unit>?) -> Unit = {
        it?.consume()?.run {
            setFragmentNavigationResult(key = ASSET_FILTER_PREFERENCES_CHANGED_KEY, value = true)
            navBack()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        iniObservers()
    }

    private fun initUi() {
        configureToolbar()
        configureSwitchButtons()
    }

    private fun configureToolbar() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.done, onClick = ::onDoneButtonClick))
    }

    private fun onDoneButtonClick() {
        assetFilterViewModel.saveChanges()
    }

    private fun configureSwitchButtons() {
        with(binding) {
            with(assetFilterViewModel) {
                hideNoBalanceAssetsSwitch.setOnCheckedChangeListener { _, isChecked ->
                    onShowZeroBalanceAssetsSwitchCheckChanged(isChecked)
                }
                displayNFTInAssetsSwitch.setOnCheckedChangeListener { _, isChecked ->
                    onDisplayNFTInAssetsSwitchCheckChanged(isChecked)
                }
                displayOptedInNFTInAssetsSwitch.setOnCheckedChangeListener { _, isChecked ->
                    onDisplayOptedInNFTInAssetsSwitchCheckChanged(isChecked)
                }
            }
        }
    }

    private fun iniObservers() {
        with(assetFilterViewModel) {
            collectLatestOnLifecycle(
                flow = assetFilterPreviewFlow,
                collection = assetFilterPreviewCollector
            )
            collectLatestOnLifecycle(
                flow = assetFilterPreviewFlow.map { it?.onNavigateBackEvent },
                collection = onNavigateBackEventCollector
            )
        }
    }

    private fun initPreview(preview: AssetFilterPreview) {
        with(binding) {
            with(preview) {
                hideNoBalanceAssetsSwitch.isChecked = hideZeroBalanceAssets
                displayNFTInAssetsSwitch.isChecked = displayNFTInAssets
                with(displayOptedInNFTInAssetsSwitch) {
                    isChecked = displayOptedInNFTInAssets
                    isEnabled = isDisplayOptedInNFTInAssetsOptionActive
                }
            }
        }
    }

    companion object {
        const val ASSET_FILTER_PREFERENCES_CHANGED_KEY = "asset_filter_preferences_changed"
    }
}
