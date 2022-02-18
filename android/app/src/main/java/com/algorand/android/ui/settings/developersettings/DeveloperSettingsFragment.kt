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

package com.algorand.android.ui.settings.developersettings

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentDeveloperSettingsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class DeveloperSettingsFragment : DaggerBaseFragment(R.layout.fragment_developer_settings) {

    private val developerSettingsViewModel: DeveloperSettingsViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.developer_settings,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentDeveloperSettingsBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.nodeSettingsListItem.setOnClickListener { onNodeSettingsClick() }
        binding.dispenserListItem.setOnClickListener { onDispenserClick() }
    }

    override fun onResume() {
        super.onResume()
        binding.dispenserListItem.isVisible = developerSettingsViewModel.isConnectedToTestnet()
    }

    private fun onNodeSettingsClick() {
        nav(DeveloperSettingsFragmentDirections.actionDeveloperSettingsFragmentToNodeSettingsFragment())
    }

    private fun onDispenserClick() {
        context?.openUrl(DISPENSER_URL)
    }

    companion object {
        private const val DISPENSER_URL = "https://bank.testnet.algorand.network"
    }
}
