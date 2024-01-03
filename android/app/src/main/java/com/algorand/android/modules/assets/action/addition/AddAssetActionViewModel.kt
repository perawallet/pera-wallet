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

package com.algorand.android.modules.assets.action.addition

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.models.AssetAction
import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.assets.action.base.BaseAssetActionViewModel
import com.algorand.android.modules.assets.profile.about.domain.usecase.GetAssetDetailUseCase
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.AccountAddressUseCase
import com.algorand.android.usecase.GetFormattedTransactionFeeAmountUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class AddAssetActionViewModel @Inject constructor(
    private val accountAddressUseCase: AccountAddressUseCase,
    private val getFormattedTransactionFeeAmountUseCase: GetFormattedTransactionFeeAmountUseCase,
    assetDetailUseCase: SimpleAssetDetailUseCase,
    simpleCollectibleUseCase: SimpleCollectibleUseCase,
    getAssetDetailUseCase: GetAssetDetailUseCase,
    verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    savedStateHandle: SavedStateHandle
) : BaseAssetActionViewModel(
    assetDetailUseCase,
    simpleCollectibleUseCase,
    getAssetDetailUseCase,
    verificationTierConfigurationDecider
) {

    private val assetAction: AssetAction = savedStateHandle.getOrThrow(ASSET_ACTION_KEY)
    val accountAddress: String = assetAction.publicKey.orEmpty()
    val shouldWaitForConfirmation = savedStateHandle.getOrElse(
        SHOULD_WAIT_FOR_CONFIRMATION_KEY,
        DEFAULT_WAIT_FOR_CONFIRMATION_PARAM
    )

    override val assetId: Long = assetAction.assetId

    init {
        fetchAssetDescription(assetId)
    }

    // TODO: Create [AssetActionUseCase] and get the whole UI related things from there
    fun getAccountName(): BaseAccountAddress.AccountAddress {
        return accountAddressUseCase.createAccountAddress(accountAddress)
    }

    fun getTransactionFee(): String {
        return getFormattedTransactionFeeAmountUseCase.getTransactionFee()
    }
}
