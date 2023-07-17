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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.AccountCreation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basefoundaccount.selection.ui.BaseFoundAccountSelectionFragment
import com.algorand.android.modules.basefoundaccount.selection.ui.BaseFoundAccountSelectionViewModel
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RekeyedAccountSelectionFragment : BaseFoundAccountSelectionFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val rekeyedAccountSelectionViewModel by viewModels<RekeyedAccountSelectionViewModel>()
    override val baseFoundAccountSelectionViewModel: BaseFoundAccountSelectionViewModel
        get() = rekeyedAccountSelectionViewModel

    private val showAccountCountExceedErrorEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { showMaxAccountLimitExceededError() }
    }

    private val navToNameRegistrationEventCollector: suspend (Event<AccountCreation>?) -> Unit = { event ->
        event?.consume()?.run { navToNameRegistration(this) }
    }

    private val primaryButtonStateCollector: suspend (Boolean) -> Unit = { isEnabled ->
        binding.primaryActionButton.isEnabled = isEnabled
    }

    private val secondaryButtonTextResIdCollector: suspend (Int?) -> Unit = { stringResId ->
        stringResId?.let { safeStringResId -> binding.secondaryActionButton.setText(safeStringResId) }
    }

    private val primaryButtonTextResIdCollector: suspend (Int?) -> Unit = { stringResId ->
        stringResId?.let { safeStringResId -> binding.primaryActionButton.setText(safeStringResId) }
    }

    override fun initUi() {
        super.initUi()
        binding.primaryActionButton.apply {
            setOnClickListener { rekeyedAccountSelectionViewModel.onChosenAccountAddClick() }
            show()
        }
        binding.secondaryActionButton.apply {
            setOnClickListener { rekeyedAccountSelectionViewModel.onSkipForNowClick() }
            show()
        }
    }

    override fun initObservers() {
        super.initObservers()
        with(rekeyedAccountSelectionViewModel.foundAccountSelectionFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it.primaryButtonTextResId },
                collection = primaryButtonTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.secondaryButtonTextResId },
                collection = secondaryButtonTextResIdCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isPrimaryButtonEnable },
                collection = primaryButtonStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.navToNameRegistrationEvent },
                collection = navToNameRegistrationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showAccountCountExceedErrorEvent },
                collection = showAccountCountExceedErrorEventCollector
            )
        }
    }

    override fun navToAccountInformationBottomSheet(accountAddress: String) {
        nav(
            RekeyedAccountSelectionFragmentDirections
                .actionRekeyedAccountSelectionFragmentToRekeyedAccountInformationFragment(accountAddress)
        )
    }

    override fun onAccountSelected(accountAddress: String) {
        rekeyedAccountSelectionViewModel.onAccountSelected(accountAddress)
    }

    private fun navToNameRegistration(accountCreation: AccountCreation) {
        nav(
            RekeyedAccountSelectionFragmentDirections
                .actionRekeyedAccountSelectionFragmentToRecoverAccountNameRegistrationFragment(accountCreation)
        )
    }
}
