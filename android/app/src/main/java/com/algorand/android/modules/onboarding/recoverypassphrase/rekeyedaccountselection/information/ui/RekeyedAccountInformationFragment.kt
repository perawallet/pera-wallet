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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basefoundaccount.information.ui.BaseFoundAccountInformationFragment
import com.algorand.android.modules.basefoundaccount.information.ui.BaseFoundAccountInformationViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyedAccountInformationFragment : BaseFoundAccountInformationFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val rekeyedAccountInformationViewModel: RekeyedAccountInformationViewModel by viewModels()

    override val baseFoundAccountInformationViewModel: BaseFoundAccountInformationViewModel
        get() = rekeyedAccountInformationViewModel
}
