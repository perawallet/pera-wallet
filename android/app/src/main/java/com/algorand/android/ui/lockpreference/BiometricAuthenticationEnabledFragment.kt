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

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.ui.lockpreference.BiometricAuthenticationEnabledFragmentDirections.Companion.actionBiometricAuthenticationEnabledFragmentToHomeNavigation
import com.google.android.material.button.MaterialButton

class BiometricAuthenticationEnabledFragment : BaseInfoFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun setImageView(imageView: ImageView) {
        val icon = R.drawable.ic_check
        imageView.setImageResource(icon)
        imageView.setColorFilter(ContextCompat.getColor(requireContext(), R.color.infoImageColor))
    }

    override fun setTitleText(textView: TextView) {
        val title = R.string.biometric_authentication_enabled
        textView.setText(title)
    }

    override fun setDescriptionText(textView: TextView) {
        val description = R.string.your_passcode_has_been_verified
        textView.setText(description)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        val buttonText = R.string.go_to_accounts
        materialButton.setText(buttonText)
        materialButton.setOnClickListener { navigateToHomeNavigation() }
    }

    private fun navigateToHomeNavigation() {
        nav(actionBiometricAuthenticationEnabledFragmentToHomeNavigation())
    }
}
