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

package com.algorand.android.modules.asb.createbackup.intro.ui

import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.asb.createbackup.intro.ui.model.AsbIntroPreview
import com.algorand.android.modules.asb.createbackup.intro.ui.usecase.AsbPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbIntroViewModel @Inject constructor(
    private val asbPreviewUseCase: AsbPreviewUseCase
) : BaseViewModel() {

    private val _algorandSecureBackupIntroPreviewFlow = MutableStateFlow(getInitialPreview())
    val asbIntroPreviewFlow: StateFlow<AsbIntroPreview>
        get() = _algorandSecureBackupIntroPreviewFlow

    fun onStartClick() {
        _algorandSecureBackupIntroPreviewFlow.update { preview ->
            asbPreviewUseCase.updatePreviewAfterStartClick(preview)
        }
    }

    fun onLearnMoreClick() {
        _algorandSecureBackupIntroPreviewFlow.update { preview ->
            asbPreviewUseCase.updatePreviewAfterLearnMoreClick(preview)
        }
    }

    private fun getInitialPreview(): AsbIntroPreview {
        return asbPreviewUseCase.getInitialPreview()
    }
}
