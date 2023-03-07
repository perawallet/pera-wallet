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

package com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RekeyToAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        titleResId = R.string.select_account
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val rekeyToAccountSelectionViewModel by viewModels<RekeyToAccountSelectionViewModel>()

    private val rekeyToAccountSelectionListCollector: suspend (List<BaseAccountSelectionListItem>?) -> Unit = {
        accountAdapter.submitList(it)
    }

    private val screenStateCollector: suspend (ScreenState?) -> Unit = { screenState ->
        setScreenStateViewVisibility(screenState != null)
        if (screenState != null) setScreenStateView(screenState)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
    }

    override fun initObservers() {
        with(rekeyToAccountSelectionViewModel.rekeyToAccountSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.accountSelectionListItem },
                collection = rekeyToAccountSelectionListCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.screenState },
                collection = screenStateCollector
            )
        }
    }

    override fun onAccountSelected(publicKey: String) {
        val authAccountAddress = publicKey
        val accountAddress = rekeyToAccountSelectionViewModel.accountAddress
        nav(
            RekeyToAccountSelectionFragmentDirections
                .actionRekeyToAccountSelectionFragmentToRekeyToStandardAccountConfirmationFragment(
                    accountAddress = accountAddress,
                    authAccountAddress = authAccountAddress
                )
        )
    }
}
