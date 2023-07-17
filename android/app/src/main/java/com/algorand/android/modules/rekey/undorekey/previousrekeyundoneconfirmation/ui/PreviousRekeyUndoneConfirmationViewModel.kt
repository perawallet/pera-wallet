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

package com.algorand.android.modules.rekey.undorekey.previousrekeyundoneconfirmation.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.rekey.undorekey.previousrekeyundoneconfirmation.ui.usecase.PreviousRekeyUndoneConfirmationPreviewUseCase
import com.algorand.android.utils.AccountDisplayName
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class PreviousRekeyUndoneConfirmationViewModel @Inject constructor(
    private val previousRekeyUndoneConfirmationPreviewUseCase: PreviousRekeyUndoneConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val navArgs = PreviousRekeyUndoneConfirmationBottomSheetArgs.fromSavedStateHandle(savedStateHandle)
    private val accountAddress = navArgs.accountAddress
    private val authAccountAddress = navArgs.authAccountAddress

    val accountDisplayName: AccountDisplayName
        get() = previousRekeyUndoneConfirmationPreviewUseCase.getAccountDisplayName(accountAddress)

    val authAccountDisplayName: AccountDisplayName
        get() = previousRekeyUndoneConfirmationPreviewUseCase.getAccountDisplayName(authAccountAddress)
}
