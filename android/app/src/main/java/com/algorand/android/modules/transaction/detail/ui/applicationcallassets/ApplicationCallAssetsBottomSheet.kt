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

package com.algorand.android.modules.transaction.detail.ui.applicationcallassets

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetApplicationCallAssetsBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.transaction.detail.domain.model.ApplicationCallAssetInformationPreview
import com.algorand.android.modules.transaction.detail.ui.adapter.ApplicationCallAssetInformationAdapter
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ApplicationCallAssetsBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_application_call_assets,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.assets,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )
    private val binding by viewBinding(BottomSheetApplicationCallAssetsBinding::bind)

    private val applicationCallAssetsViewModel by viewModels<ApplicationCallAssetsViewModel>()

    private val applicationCallAssetInformationAdapter = ApplicationCallAssetInformationAdapter()

    private val assetItemConfigurationCollector: suspend (ApplicationCallAssetInformationPreview?) -> Unit = {
        applicationCallAssetInformationAdapter.submitList(it?.applicationCallAssetInformationListItems)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        initToolbar()
        binding.assetsRecyclerView.adapter = applicationCallAssetInformationAdapter
    }

    private fun initToolbar() {
        binding.customToolbar.configure(toolbarConfiguration)
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            applicationCallAssetsViewModel.assetItemConfigurationFlow,
            assetItemConfigurationCollector
        )
    }
}
