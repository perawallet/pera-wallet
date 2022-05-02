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

package com.algorand.android.ui.lock

import com.algorand.android.R
import com.algorand.android.utils.setNavigationResult
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ChangePasscodeVerificationBottomSheet : BasePasscodeVerificationBottomSheet() {

    override val titleResId: Int
        get() = R.string.enter_your_old

    override fun onPasscodeSuccess() {
        setNavigationResult(CHANGE_PASSCODE_VERIFICATION_RESULT_KEY, true)
        navBack()
    }

    companion object {
        const val CHANGE_PASSCODE_VERIFICATION_RESULT_KEY = "change_passcode_verification_result"
    }
}
