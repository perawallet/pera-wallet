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

import com.algorand.android.R
import com.algorand.android.ui.password.BasePasswordFragment
import com.algorand.android.utils.setNavigationResult
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ChangePasswordFragment : BasePasswordFragment() {

    override val initialTitleResId = R.string.enter_your_new_six_digit_pin
    override val nextTitleResId = R.string.re_enter_your_new_six_digit_pin

    override fun handleNextNavigation() {
        setNavigationResult(IS_PASSWORD_CHOSEN_KEY, true)
        navBack()
    }

    companion object {
        const val IS_PASSWORD_CHOSEN_KEY = "isPasswordChosen"
    }
}
