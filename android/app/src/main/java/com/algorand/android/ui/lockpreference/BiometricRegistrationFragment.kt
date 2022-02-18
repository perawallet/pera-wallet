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
package com.algorand.android.ui.lockpreference

import android.content.SharedPreferences
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.ui.lockpreference.BiometricRegistrationFragmentDirections.Companion.actionBiometricRegistrationFragmentToBiometricAuthenticationEnabledFragment
import com.algorand.android.ui.lockpreference.BiometricRegistrationFragmentDirections.Companion.actionBiometricRegistrationFragmentToHomeNavigation
import com.algorand.android.utils.alertDialog
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.preference.setBiometricRegistrationPreference
import com.algorand.android.utils.showBiometricAuthentication
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject

@AndroidEntryPoint
class BiometricRegistrationFragment : BaseInfoFragment() {

    @Inject
    lateinit var sharedPref: SharedPreferences

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration =
        FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun setImageView(imageView: ImageView) {
        val icon = R.drawable.ic_faceid
        imageView.setImageResource(icon)
        imageView.setColorFilter(ContextCompat.getColor(requireContext(), R.color.infoImageColor))
    }

    override fun setTitleText(textView: TextView) {
        val title = R.string.enable_biometric_authentication
        textView.setText(title)
    }

    override fun setDescriptionText(textView: TextView) {
        val description = R.string.your_faceid_or_fingerprintid
        textView.setText(description)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        val buttonText = R.string.enable_biometric_authentication
        materialButton.setText(buttonText)
        materialButton.setOnClickListener { checkBiometricAuthentication() }
    }

    override fun setSecondButton(materialButton: MaterialButton) {
        val buttonText = R.string.do_not_use
        materialButton.apply {
            setText(buttonText)
            show()
            setOnClickListener { navigateToHomeNavigation() }
        }
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
        nav(actionBiometricRegistrationFragmentToBiometricAuthenticationEnabledFragment())
    }

    private fun navigateToHomeNavigation() {
        nav(actionBiometricRegistrationFragmentToHomeNavigation())
    }
}
