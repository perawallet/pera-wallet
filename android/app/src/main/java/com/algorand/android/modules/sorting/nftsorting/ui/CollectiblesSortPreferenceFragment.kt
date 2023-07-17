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

package com.algorand.android.modules.sorting.nftsorting.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentCollectibleSortPreferenceBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.sorting.nftsorting.ui.model.CollectibleSortPreferencePreview
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class CollectiblesSortPreferenceFragment : BaseFragment(R.layout.fragment_collectible_sort_preference) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.sort,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentCollectibleSortPreferenceBinding::bind)

    private val collectibleSortPreferenceViewModel by viewModels<CollectibleSortPreferenceViewModel>()

    private val collectibleSortPreferencePreviewObserver: suspend (CollectibleSortPreferencePreview?) -> Unit = {
        it?.let { preview ->
            initCollectibleSortPreferencePreview(preview)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initToolbar()
        initUi()
        initObservers()
    }

    private fun initToolbar() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.done, R.color.link_primary, ::onDoneClick))
    }

    private fun initUi() {
        with(binding) {
            with(collectibleSortPreferenceViewModel) {
                alphabeticallyAscendingRadioButton.setOnClickListener { onAlphabeticallyAscendingSelected() }
                alphabeticallyDescendingRadioButton.setOnClickListener { onAlphabeticallyDescendingSelected() }
                newestToOldestRadioButton.setOnClickListener { onNewestToOldestSelected() }
                oldestToNewestRadioButton.setOnClickListener { onOldestToNewestSelected() }
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            collectibleSortPreferenceViewModel.collectibleSortPreferencePreviewFlow.collectLatest(
                collectibleSortPreferencePreviewObserver
            )
        }
    }

    private fun initCollectibleSortPreferencePreview(preview: CollectibleSortPreferencePreview) {
        with(binding) {
            with(preview) {
                alphabeticallyAscendingRadioButton.isChecked = isAlphabeticallyAscendingSelected
                alphabeticallyDescendingRadioButton.isChecked = isAlphabeticallyDescendingSelected
                oldestToNewestRadioButton.isChecked = isOldestToNewestSelected
                newestToOldestRadioButton.isChecked = isNewestToOldestSelected
            }
        }
    }

    private fun onDoneClick() {
        collectibleSortPreferenceViewModel.savePreferenceChanges()
        navBack()
    }
}
