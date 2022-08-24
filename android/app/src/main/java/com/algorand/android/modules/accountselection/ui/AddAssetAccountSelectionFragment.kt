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

package com.algorand.android.modules.accountselection.ui

import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.accountselection.ui.model.AddAssetAccountSelectionPreview
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class AddAssetAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_account,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val addAssetAccountSelectionViewModel by viewModels<AddAssetAccountSelectionViewModel>()

    private val addAssetAccountSelectionPreviewCollector: suspend (AddAssetAccountSelectionPreview) -> Unit = {
        accountAdapter.submitList(it.accountSelectionListItems)
    }

    override fun onAccountSelected(publicKey: String) {
        val addAssetAction = addAssetAccountSelectionViewModel.getAddAssetAction(publicKey)
        nav(
            AddAssetAccountSelectionFragmentDirections
                .actionAddAssetAccountSelectionFragmentToAddAssetActionBottomSheet(addAssetAction)
        )
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            addAssetAccountSelectionViewModel.addAssetAccountSelectionPreviewFlow.collect(
                addAssetAccountSelectionPreviewCollector
            )
        }
    }
}
