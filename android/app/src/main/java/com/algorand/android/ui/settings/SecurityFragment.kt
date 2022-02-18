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

package com.algorand.android.ui.settings

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentSecurityBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.isBiometricAvailable
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SecurityFragment : DaggerBaseFragment(R.layout.fragment_security) {

    private val binding by viewBinding(FragmentSecurityBinding::bind)

    private val securityViewModel: SecurityViewModel by viewModels()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        titleResId = R.string.security,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            setChangePasswordListItem.setOnClickListener { onClickSetChangePassword() }
            biometricSwitch.isChecked = securityViewModel.isBiometricActive()

            // If the user did not register fingerprint or face id before to the device or does support the biometric
            // auth, then the biometric switch won't show
            enableFaceIDTouchIDListItem.isVisible = context?.isBiometricAvailable() == true
            initSwitchChangeListeners()
        }
    }

    private fun initSwitchChangeListeners() {
        binding.biometricSwitch.setOnCheckedChangeListener { _, isChecked ->
            if (!isChecked) {
                securityViewModel.setBiometricRegistrationPreference(isChecked)
            } else {
                checkBiometricAuthentication()
            }
        }
    }

    private fun checkBiometricAuthentication() {
        activity?.showBiometricAuthentication(
            getString(R.string.app_name),
            getString(R.string.please_scan_your_fingerprint_or),
            getString(R.string.cancel),
            successCallback = { updateSwitchMaterialState(true) },
            hardwareErrorCallback = { updateSwitchMaterialState(false) },
            failCallBack = { updateSwitchMaterialState(false) }
        )
    }

    private fun updateSwitchMaterialState(isChecked: Boolean) {
        securityViewModel.setBiometricRegistrationPreference(isChecked)
        binding.biometricSwitch.isChecked = isChecked
    }

    private fun onClickSetChangePassword() {
        nav(SecurityFragmentDirections.actionSecurityFragmentToChangePasswordFragment())
    }
}
