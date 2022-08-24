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

package com.algorand.android.modules.assets.assetsort.ui.assetsortpreference

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetSortPreferenceBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.model.AssetSortPreferencePreview
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class AssetSortPreferenceFragment : BaseFragment(R.layout.fragment_asset_sort_preference) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.sort,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAssetSortPreferenceBinding::bind)

    private val assetSortPreferenceViewModel by viewModels<AssetSortPreferenceViewModel>()

    private val assetSortPreferencePreviewObserver: suspend (AssetSortPreferencePreview) -> Unit = { preview ->
        initAssetSortPreferencePreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initToolbar()
        initUi()
        initObservers()
    }

    private fun initToolbar() {
        getAppToolbar()?.addButtonToEnd(TextButton(R.string.done, R.color.link_primary, ::onDoneClick))
    }

    private fun initUi() {
        with(binding) {
            with(assetSortPreferenceViewModel) {
                alphabeticallyAscendingRadioButton.setOnClickListener { onAlphabeticallyAscendingSelected() }
                alphabeticallyDescendingRadioButton.setOnClickListener { onAlphabeticallyDescendingSelected() }
                balanceAscendingRadioButton.setOnClickListener { onBalanceAscendingSelected() }
                balanceDescendingRadioButton.setOnClickListener { onBalanceDescendingSelected() }
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            assetSortPreferenceViewModel.assetSortPreferencePreviewFlow.collect(assetSortPreferencePreviewObserver)
        }
    }

    private fun initAssetSortPreferencePreview(preview: AssetSortPreferencePreview) {
        with(binding) {
            with(preview) {
                alphabeticallyAscendingRadioButton.isChecked = isAlphabeticallyAscendingSelected
                alphabeticallyDescendingRadioButton.isChecked = isAlphabeticallyDescendingSelected
                balanceAscendingRadioButton.isChecked = isBalanceAscendingSelected
                balanceDescendingRadioButton.isChecked = isBalanceDescendingSelected
            }
        }
    }

    private fun onDoneClick() {
        assetSortPreferenceViewModel.savePreferenceChanges()
        navBack()
    }
}
