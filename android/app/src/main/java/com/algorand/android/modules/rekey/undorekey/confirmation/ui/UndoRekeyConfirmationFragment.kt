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

package com.algorand.android.modules.rekey.undorekey.confirmation.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationFragment
import com.algorand.android.modules.rekey.baserekeyconfirmation.ui.BaseRekeyConfirmationViewModel
import com.algorand.android.modules.rekey.undorekey.previousrekeyundoneconfirmation.ui.PreviousRekeyUndoneConfirmationBottomSheet.Companion.PREVIOUS_REKEY_UNDONE_CONFIRMATION_KEY
import com.algorand.android.utils.useFragmentResultListenerValue
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class UndoRekeyConfirmationFragment : BaseRekeyConfirmationFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val undoRekeyConfirmationViewModel by viewModels<UndoRekeyConfirmationViewModel>()

    override val baseRekeyConfirmationViewModel: BaseRekeyConfirmationViewModel
        get() = undoRekeyConfirmationViewModel

    override fun onStart() {
        super.onStart()
        startSavedStateListener()
    }

    private fun startSavedStateListener() {
        useFragmentResultListenerValue<Boolean>(PREVIOUS_REKEY_UNDONE_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                onSendTransaction()
            }
        }
    }

    override fun navToResultInfoFragment() {
        val accountAddress = undoRekeyConfirmationViewModel.accountAddress
        nav(
            UndoRekeyConfirmationFragmentDirections
                .actionUndoRekeyConfirmationFragmentToUndoRekeyVerifyInfoFragment(accountAddress)
        )
    }

    override fun navToRekeyedAccountConfirmationBottomSheet() {
        val accountAddress = undoRekeyConfirmationViewModel.accountAddress
        val authAccountAddress = undoRekeyConfirmationViewModel.getAccountAuthAddress()
        nav(
            UndoRekeyConfirmationFragmentDirections
                .actionUndoRekeyConfirmationFragmentToPreviousRekeyUndoneConfirmationBottomSheet(
                    authAccountAddress = authAccountAddress,
                    accountAddress = accountAddress
                )
        )
    }

    override fun onConfirmClick() {
        undoRekeyConfirmationViewModel.onConfirmRekeyClick()
    }

    override fun onSendTransaction() {
        val rekeyTx = undoRekeyConfirmationViewModel.createRekeyToStandardAccountTransaction() ?: return
        sendTransaction(rekeyTx)
    }

    override fun onTransactionLoading() {
        undoRekeyConfirmationViewModel.onTransactionSigningStarted()
    }

    override fun onTransactionFailed() {
        undoRekeyConfirmationViewModel.onTransactionSigningFailed()
    }

    override fun onTransactionSigned(signedTransactionDetail: SignedTransactionDetail) {
        if (
            signedTransactionDetail is SignedTransactionDetail.RekeyToStandardAccountOperation ||
            signedTransactionDetail is SignedTransactionDetail.RekeyOperation
        ) {
            undoRekeyConfirmationViewModel.sendRekeyTransaction(signedTransactionDetail)
        }
    }
}
