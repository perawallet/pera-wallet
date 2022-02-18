/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.assetdetail

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.PendingReward
import com.algorand.android.usecase.PendingRewardUseCase
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class RewardsViewModel @ViewModelInject constructor(
    private val pendingRewardUseCase: PendingRewardUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val publicKey = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)

    private val _pendingRewardFlow = MutableStateFlow(pendingRewardUseCase.getInitialPendingReward())
    val pendingRewardFlow: StateFlow<PendingReward> = _pendingRewardFlow

    init {
        initPendingRewardFlow()
    }

    private fun initPendingRewardFlow() {
        viewModelScope.launch {
            pendingRewardUseCase.getPendingRewardFlow(publicKey, ALGORAND_ID, viewModelScope).collectLatest {
                _pendingRewardFlow.emit(it)
            }
        }
    }

    companion object {
        private const val PUBLIC_KEY = "publicKey"
    }
}
