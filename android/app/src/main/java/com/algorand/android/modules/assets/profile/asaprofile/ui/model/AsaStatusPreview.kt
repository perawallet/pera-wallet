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

package com.algorand.android.modules.assets.profile.asaprofile.ui.model

import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.utils.AssetName

sealed class AsaStatusPreview {

    abstract val statusLabelTextResId: Int
    abstract val peraButtonState: PeraButtonState
    abstract val actionButtonTextResId: Int

    data class AccountSelectionStatus(
        override val statusLabelTextResId: Int,
        override val peraButtonState: PeraButtonState,
        override val actionButtonTextResId: Int
    ) : AsaStatusPreview()

    data class AdditionStatus(
        override val statusLabelTextResId: Int,
        override val peraButtonState: PeraButtonState,
        override val actionButtonTextResId: Int,
        val accountName: BaseAccountAddress.AccountAddress
    ) : AsaStatusPreview()

    sealed class RemovalStatus : AsaStatusPreview() {

        data class AssetRemovalStatus(
            override val statusLabelTextResId: Int,
            override val peraButtonState: PeraButtonState,
            override val actionButtonTextResId: Int,
            val formattedAccountBalance: String?,
            val assetShortName: AssetName?
        ) : RemovalStatus()

        data class CollectibleRemovalStatus(
            override val statusLabelTextResId: Int,
            override val peraButtonState: PeraButtonState,
            override val actionButtonTextResId: Int,
            val accountName: BaseAccountAddress.AccountAddress
        ) : RemovalStatus()
    }

    data class TransferStatus(
        override val statusLabelTextResId: Int,
        override val peraButtonState: PeraButtonState,
        override val actionButtonTextResId: Int,
        val formattedAccountBalance: String,
        val assetShortName: AssetName?
    ) : AsaStatusPreview()
}
