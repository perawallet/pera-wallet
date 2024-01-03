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

package com.algorand.android.modules.rekey.previouslyrekeyedaccountconfirmation.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.rekey.previouslyrekeyedaccountconfirmation.ui.usecase.RekeyedAccountRekeyConfirmationPreviewUseCase
import com.algorand.android.utils.AccountDisplayName
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class RekeyedAccountRekeyConfirmationViewModel @Inject constructor(
    private val rekeyedAccountRekeyConfirmationPreviewUseCase: RekeyedAccountRekeyConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val navArgs = RekeyedAccountRekeyConfirmationBottomSheetArgs.fromSavedStateHandle(savedStateHandle)
    private val accountAddress: String = navArgs.accountAddress
    private val authAccountAddress: String = navArgs.authAccountAddress

    val accountDisplayName: AccountDisplayName
        get() = rekeyedAccountRekeyConfirmationPreviewUseCase.getAccountDisplayName(accountAddress)

    val authAccountDisplayName: AccountDisplayName
        get() = rekeyedAccountRekeyConfirmationPreviewUseCase.getAccountDisplayName(authAccountAddress)
}
