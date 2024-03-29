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

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basesingleaccountselection.ui.BaseSingleAccountSelectionFragment
import com.algorand.android.modules.basesingleaccountselection.ui.BaseSingleAccountSelectionViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyToStandardAccountSelectionFragment : BaseSingleAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override val singleAccountSelectionViewModel: BaseSingleAccountSelectionViewModel
        get() = rekeyToStandardAccountSelectionViewModel
    private val rekeyToStandardAccountSelectionViewModel by viewModels<RekeyToStandardAccountSelectionViewModel>()

    override fun onAccountSelected(accountAddress: String) {
        nav(
            RekeyToStandardAccountSelectionFragmentDirections
                .actionRekeyToAccountSelectionFragmentToRekeyToStandardAccountConfirmationFragment(
                    accountAddress = rekeyToStandardAccountSelectionViewModel.accountAddress,
                    authAccountAddress = accountAddress
                )
        )
    }
}
