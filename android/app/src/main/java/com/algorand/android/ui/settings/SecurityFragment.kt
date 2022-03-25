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

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentSecurityBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.lock.ChangePasscodeVerificationBottomSheet.Companion.CHANGE_PASSCODE_VERIFICATION_RESULT_KEY
import com.algorand.android.ui.lock.DisablePasscodeVerificationBottomSheet.Companion.DISABLE_VERIFICATION_RESULT_KEY
import com.algorand.android.utils.isBiometricAvailable
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
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

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val isBiometricEnabledObserver = Observer<Boolean> { isChecked ->
        securityViewModel.setBiometricRegistrationPreference(isChecked)
        binding.biometricSwitch.isChecked = isChecked
    }

    private val isPasswordChosenObserver = Observer<Boolean> { isEnabled ->
        changeSecurityPreferencesGroupVisibility(isEnabled)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initSwitchChangeListeners()
        initObservers()
    }

    override fun onResume() {
        super.onResume()
        initDialogSavedStateListener()
    }

    private fun initUi() {
        binding.setChangePasswordListItem.setOnClickListener { navToChangePasscodeVerificationBottomSheet() }
    }

    private fun navToChangePasscodeVerificationBottomSheet() {
        nav(SecurityFragmentDirections.actionSecurityFragmentToChangePasscodeVerificationBottomSheet())
    }

    private fun initObservers() {
        with(securityViewModel) {
            isPasswordChosenLiveData.observe(viewLifecycleOwner, isPasswordChosenObserver)
            isBiometricEnabledLiveData.observe(viewLifecycleOwner, isBiometricEnabledObserver)
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun initSwitchChangeListeners() {
        with(binding) {
            biometricSwitch.setOnClickListener {
                if (!biometricSwitch.isChecked) {
                    updateSwitchMaterialState(biometricSwitch.isChecked)
                    return@setOnClickListener
                }
                checkBiometricAuthentication()
            }

            pinCodeSwitch.setOnTouchListener { _, _ ->
                onEnablePinCodeTouch()
                true
            }
        }
    }

    private fun onEnablePinCodeTouch() {
        if (securityViewModel.isPasscodeSet()) {
            nav(SecurityFragmentDirections.actionSecurityFragmentToDisablePasscodeVerificationBottomSheet())
        } else {
            navToSetChangePasscodeFragment()
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.securityFragment) {
            useSavedStateValue<Boolean>(ChangePasswordFragment.IS_PASSWORD_CHOSEN_KEY) {
                securityViewModel.updatePinCodeEnabledFlow(it)
            }
            useSavedStateValue<Boolean>(CHANGE_PASSCODE_VERIFICATION_RESULT_KEY) { isPasscodeVerified ->
                handleChangePasscodeVerificationResult(isPasscodeVerified)
            }
            useSavedStateValue<Boolean>(DISABLE_VERIFICATION_RESULT_KEY) { isPasscodeVerified ->
                handleDisablePasscodeVerificationResult(isPasscodeVerified)
            }
        }
    }

    private fun handleDisablePasscodeVerificationResult(isPasscodeVerified: Boolean) {
        if (isPasscodeVerified) {
            securityViewModel.setPasswordPreferencesAsDisabled()
            securityViewModel.updatePinCodeEnabledFlow(false)
        }
    }

    private fun handleChangePasscodeVerificationResult(isPasscodeVerified: Boolean) {
        if (isPasscodeVerified) navToSetChangePasscodeFragment()
    }

    private fun checkBiometricAuthentication() {
        activity?.showBiometricAuthentication(
            getString(R.string.app_name),
            getString(R.string.please_scan_your_fingerprint_or),
            getString(R.string.cancel),
            successCallback = { updateSwitchMaterialState(true) },
            hardwareErrorCallback = { updateSwitchMaterialState(false) },
            failCallBack = { updateSwitchMaterialState(false) },
            userCancelledErrorCallback = { updateSwitchMaterialState(false) },
            lockedOutErrorCallback = { updateSwitchMaterialState(false) },
            timeOutErrorCallback = { updateSwitchMaterialState(false) }
        )
    }

    private fun updateSwitchMaterialState(isChecked: Boolean) {
        securityViewModel.updateBiometricEnabledFlow(isChecked)
    }

    private fun navToSetChangePasscodeFragment() {
        nav(SecurityFragmentDirections.actionSecurityFragmentToChangePasswordFragment())
    }

    private fun changeSecurityPreferencesGroupVisibility(isVisible: Boolean) {
        with(binding) {
            pinCodeSwitch.isChecked = isVisible
            securityPreferencesTextView.isVisible = isVisible
            setChangePasswordListItem.isVisible = isVisible

            // If the user did not register fingerprint or face id before to the device or does support the biometric
            // auth, then the biometric switch won't show
            enableFaceIDTouchIDListItem.isVisible = isVisible && context?.isBiometricAvailable() == true
        }
    }
}
