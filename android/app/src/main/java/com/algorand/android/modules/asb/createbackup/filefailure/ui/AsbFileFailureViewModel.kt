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

package com.algorand.android.modules.asb.createbackup.filefailure.ui

import com.algorand.android.modules.asb.createbackup.filefailure.ui.model.AsbFileFailurePreview
import com.algorand.android.modules.asb.createbackup.filefailure.ui.usecase.AsbFileFailurePreviewUseCase
import com.algorand.android.modules.baseresult.ui.BaseResultViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class AsbFileFailureViewModel @Inject constructor(
    private val asbFileFailurePreviewUseCase: AsbFileFailurePreviewUseCase
) : BaseResultViewModel() {

    private val asbFileFailurePreviewFlow = MutableStateFlow(getAsbFileFailurePreview())
    override val baseResultPreviewFlow: StateFlow<AsbFileFailurePreview> get() = asbFileFailurePreviewFlow

    private fun getAsbFileFailurePreview(): AsbFileFailurePreview {
        return asbFileFailurePreviewUseCase.getAsbFileFailurePreview()
    }
}
