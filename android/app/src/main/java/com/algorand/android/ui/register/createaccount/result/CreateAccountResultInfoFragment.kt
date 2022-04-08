/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ui.register.createaccount.result

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.ui.common.BaseInfoFragment
import com.algorand.android.utils.extensions.show
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class CreateAccountResultInfoFragment : BaseInfoFragment() {
    override val fragmentConfiguration = FragmentConfiguration()

    private val createAccountResultInfoViewModel: CreateAccountResultInfoViewModel by viewModels()

    override fun setImageView(imageView: ImageView) {
        with(imageView) {
            setImageResource(R.drawable.ic_check)
            setColorFilter(ContextCompat.getColor(requireContext(), R.color.info_image_color))
        }
    }

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.account_is_verified)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.setText(R.string.welcome_to_pera_your_account)
    }

    override fun setFirstButton(materialButton: MaterialButton) {
        with(materialButton) {
            setText(R.string.start_using_pera)
            setOnClickListener { onStartUsingPeraClick() }
        }
    }

    override fun setSecondButton(materialButton: MaterialButton) {
        with(materialButton) {
            setText(R.string.buy_algo)
            show()
            setOnClickListener { navToMoonpayNavigation() }
        }
    }

    private fun onStartUsingPeraClick() {
        if (createAccountResultInfoViewModel.shouldForceLockNavigation()) {
            navToForceLockNavigation()
        } else {
            navToHomeNavigation()
        }
    }

    private fun navToHomeNavigation() {
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }

    private fun navToForceLockNavigation() {
        nav(LoginNavigationDirections.actionToLockPreferenceNavigation(shouldNavigateHome = true))
    }

    private fun navToMoonpayNavigation() {
        nav(CreateAccountResultInfoFragmentDirections.actionCreateAccountResultInfoFragmentToMoonpayNavigation())
    }
}
