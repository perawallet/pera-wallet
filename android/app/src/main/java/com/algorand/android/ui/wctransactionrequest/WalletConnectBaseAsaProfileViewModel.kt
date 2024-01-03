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

package com.algorand.android.ui.wctransactionrequest

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.assets.profile.asaprofile.base.BaseAsaProfileViewModel
import com.algorand.android.modules.assets.profile.asaprofile.ui.usecase.AsaProfilePreviewUseCase
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class WalletConnectBaseAsaProfileViewModel @Inject constructor(
    private val savedStateHandle: SavedStateHandle,
    asaProfilePreviewUseCase: AsaProfilePreviewUseCase
) : BaseAsaProfileViewModel(asaProfilePreviewUseCase) {

    override val accountAddress: String? get() = savedStateHandle.getOrElse<String?>(ACCOUNT_ADDRESS_KEY, null)
    override val assetId: Long = savedStateHandle.getOrThrow<Long>(ASSET_ID_KEY)

    init {
        initAsaPreviewFlow()
    }

    fun setSelectedAccountAddress(accountAddress: String) {
        savedStateHandle.set(ACCOUNT_ADDRESS_KEY, accountAddress)
    }
}
