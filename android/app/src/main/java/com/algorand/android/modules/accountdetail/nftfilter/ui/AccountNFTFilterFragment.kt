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

package com.algorand.android.modules.accountdetail.nftfilter.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountNftFilterBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.accountdetail.nftfilter.ui.model.AccountNFTFilterPreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountNFTFilterFragment : BaseFragment(R.layout.fragment_account_nft_filter) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.filter_nfts,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAccountNftFilterBinding::bind)

    private val accountNFTFilterViewModel by viewModels<AccountNFTFilterViewModel>()

    private val accountNFTFilterPreviewCollector: suspend (AccountNFTFilterPreview?) -> Unit = { preview ->
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
        with(accountNFTFilterViewModel) {
            collectOnLifecycle(
                flow = accountNFTFilterPreviewFlow,
                collection = accountNFTFilterPreviewCollector
            )
            collectLatestOnLifecycle(
                flow = accountNFTFilterPreviewFlow.map { it?.onNavigateBackEvent },
                collection = onNavigateBackEventCollector
            )
        }
    }

    private fun configureToolbar() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.done, onClick = ::saveChanges))
    }

    private fun saveChanges() {
        accountNFTFilterViewModel.saveChanges()
    }

    private fun initUi() {
        binding.displayOptedInNFTsSwitch.setOnCheckedChangeListener { _, isChecked ->
            accountNFTFilterViewModel.onDisplayOptedInNFTsSwitchChanged(isChecked)
        }
    }

    private fun initPreview(accountNFTFilterPreview: AccountNFTFilterPreview) {
        binding.displayOptedInNFTsSwitch.isChecked = accountNFTFilterPreview.displayOptedInNFTsPreference
    }
}
