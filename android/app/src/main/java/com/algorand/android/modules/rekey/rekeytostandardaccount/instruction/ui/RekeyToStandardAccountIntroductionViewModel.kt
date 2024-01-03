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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.baseintroduction.ui.BaseIntroductionViewModel
import com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.model.RekeyToStandardAccountIntroductionPreview
import com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.usecase.RekeyToStandardAccountInstructionPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class RekeyToStandardAccountIntroductionViewModel @Inject constructor(
    private val rekeyToStandardAccountInstructionPreviewUseCase: RekeyToStandardAccountInstructionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseIntroductionViewModel() {

    private val navArgs = RekeyToStandardAccountIntroductionFragmentArgs.fromSavedStateHandle(savedStateHandle)
    val accountAddress = navArgs.accountAddress

    private val _rekeyToStandardAccountInstructionPreviewFlow = MutableStateFlow(getInitialPreview())
    override val introductionPreviewFlow: StateFlow<RekeyToStandardAccountIntroductionPreview>
        get() = _rekeyToStandardAccountInstructionPreviewFlow

    private fun getInitialPreview(): RekeyToStandardAccountIntroductionPreview {
        return rekeyToStandardAccountInstructionPreviewUseCase.getInitialRekeyToStandardAccountInstructionPreview(
            accountAddress = accountAddress
        )
    }
}
