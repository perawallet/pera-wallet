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

package com.algorand.android.ui.accounts

import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.ui.lock.BasePasscodeVerificationBottomSheet
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.showAlertDialog
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class ViewPassphraseLockBottomSheet : BasePasscodeVerificationBottomSheet() {

    override val titleResId: Int = R.string.enter_a_passcode

    private val args: ViewPassphraseLockBottomSheetArgs by navArgs()

    private val viewPassphraseLockViewModel: ViewPassphraseLockViewModel by viewModels()

    override fun onPasscodeError() {
        super.onPasscodeError()
        context?.showAlertDialog(
            getString(R.string.wrong_password),
            getString(R.string.you_should_enter_your_correct_password)
        )
    }

    override fun onPasscodeSuccess() {
        setNavigationResult(VIEW_PASSPHRASE_ADDRESS_KEY, args.publicKey)
        navBack()
    }

    override fun onStart() {
        super.onStart()
        if (viewPassphraseLockViewModel.isNotPasswordChosen()) {
            onPasscodeSuccess()
        }
    }

    companion object {
        const val VIEW_PASSPHRASE_ADDRESS_KEY = "view_passphrase_address_key"
    }
}
