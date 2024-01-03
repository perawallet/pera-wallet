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

import androidx.navigation.fragment.navArgs
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.ui.password.BasePasswordFragment
import com.algorand.android.ui.password.model.PasswordScreenType
import com.algorand.android.ui.password.model.PasswordScreenType.ReEnterScreenType
import com.algorand.android.utils.isBiometricAvailable
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ChoosePasswordFragment : BasePasswordFragment() {

    override val titleResId: Int = R.string.choose_your_six_digit_pin

    override val screenType: PasswordScreenType = ReEnterScreenType(
        nextScreenTitleResId = R.string.re_enter_your_six_digit_pin
    )

    private val choosePasswordViewModel: ChoosePasswordViewModel by viewModels()

    private val args by navArgs<ChoosePasswordFragmentArgs>()

    override fun handleNextNavigation() {
        choosePasswordViewModel.logOnboardingSetPinCodeCompletedEvent()
        if (context?.isBiometricAvailable() == true) {
            nav(ChoosePasswordFragmentDirections.actionChoosePasswordFragmentToBiometricRegistrationFragment())
        } else {
            if (args.shouldNavigateHome) {
                nav(ChoosePasswordFragmentDirections.actionChoosePasswordFragmentToHomeNavigation())
            } else {
                nav(ChoosePasswordFragmentDirections.actionPopLockPreferenceNavigation())
            }
        }
    }
}
