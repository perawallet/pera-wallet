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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationFragment
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationViewModel
import com.algorand.android.modules.rekey.previouslyrekeyedaccountconfirmation.ui.RekeyedAccountRekeyConfirmationBottomSheet.Companion.PREVIOUSLY_REKEYED_ACCOUNT_CONFIRMATION_KEY
import com.algorand.android.utils.useFragmentResultListenerValue
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyToStandardAccountConfirmationFragment : BaseRekeyConfirmationFragment() {

    override val baseRekeyConfirmationViewModel: BaseRekeyConfirmationViewModel
        get() = rekeyToStandardAccountConfirmationViewModel

    private val rekeyToStandardAccountConfirmationViewModel by viewModels<RekeyToStandardAccountConfirmationViewModel>()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onStart() {
        super.onStart()
        startSavedStateListener()
    }

    private fun startSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(PREVIOUSLY_REKEYED_ACCOUNT_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                onSendTransaction()
            }
        }
    }

    override fun navToResultInfoFragment() {
        val accountName = rekeyToStandardAccountConfirmationViewModel.accountAddress
        val authAccountName = rekeyToStandardAccountConfirmationViewModel.authAccountAddress
        nav(
            RekeyToStandardAccountConfirmationFragmentDirections
                .actionRekeyToStandardAccountConfirmationFragmentToRekeyToStandardAccountVerifyInfoFragment(
                    accountAddress = accountName,
                    authAccountAddress = authAccountName
                )
        )
    }

    override fun navToRekeyedAccountConfirmationBottomSheet() {
        val accountName = rekeyToStandardAccountConfirmationViewModel.accountAddress
        val authAccountName = rekeyToStandardAccountConfirmationViewModel.authAccountAddress
        nav(
            RekeyToStandardAccountConfirmationFragmentDirections
                .actionRekeyToStandardAccountConfirmationFragmentToRekeyedAccountRekeyConfirmationNavigation(
                    accountAddress = accountName,
                    authAccountAddress = authAccountName
                )
        )
    }

    override fun onConfirmClick() {
        rekeyToStandardAccountConfirmationViewModel.onConfirmRekeyClick()
    }

    override fun onSendTransaction() {
        val rekeyTx = rekeyToStandardAccountConfirmationViewModel.createRekeyToStandardAccountTransaction() ?: return
        sendTransaction(rekeyTx)
    }

    override fun onTransactionLoading() {
        rekeyToStandardAccountConfirmationViewModel.onTransactionSigningStarted()
    }

    override fun onTransactionFailed() {
        rekeyToStandardAccountConfirmationViewModel.onTransactionSigningFailed()
    }

    override fun onTransactionSigned(signedTransactionDetail: SignedTransactionDetail) {
        if (signedTransactionDetail is SignedTransactionDetail.RekeyToStandardAccountOperation) {
            rekeyToStandardAccountConfirmationViewModel.sendRekeyTransaction(signedTransactionDetail)
        }
    }
}
