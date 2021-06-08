/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.lockpreference

import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentBiometricRegistrationBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.ui.lockpreference.BiometricRegistrationFragmentDirections.Companion.actionBiometricRegistrationFragmentPopIncludingChoosePasswordNavigation
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.preference.setBiometricRegistrationPreference
import com.algorand.android.utils.showBiometricAuthentication
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class BiometricRegistrationFragment : DaggerBaseFragment(R.layout.fragment_biometric_registration) {

    @Inject
    lateinit var sharedPref: SharedPreferences

    override val fragmentConfiguration = FragmentConfiguration(
        statusBarConfiguration = StatusBarConfiguration(backgroundColor = R.color.tertiaryBackground)
    )

    private val binding by viewBinding(FragmentBiometricRegistrationBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.positiveButton.setOnClickListener { onPositiveButtonClick() }
        binding.cancelButton.setOnClickListener { onNegativeButtonClick() }
    }

    private fun onPositiveButtonClick() {
        checkBiometricAuthentication()
    }

    private fun checkBiometricAuthentication() {
        activity?.showBiometricAuthentication(
            getString(R.string.app_name),
            getString(R.string.please_use_biometric),
            getString(R.string.cancel),
            successCallback = {
                sharedPref.setBiometricRegistrationPreference(true)
                handleNextNavigation()
            },
            failCallBack = null,
            hardwareErrorCallback = ::showUnsuccessfulBiometricRegistrationDialog
        )
    }

    private fun showUnsuccessfulBiometricRegistrationDialog() {
        context?.alertDialog {
            setTitle(getString(R.string.warning))
            setMessage(getString(R.string.there_s_no_biometric_registration))
            setPositiveButton(R.string.ok) { dialog, _ ->
                dialog.dismiss()
                handleNextNavigation()
            }
        }?.show()
    }

    private fun handleNextNavigation() {
        nav(actionBiometricRegistrationFragmentPopIncludingChoosePasswordNavigation())
    }

    private fun onNegativeButtonClick() {
        handleNextNavigation()
    }
}
