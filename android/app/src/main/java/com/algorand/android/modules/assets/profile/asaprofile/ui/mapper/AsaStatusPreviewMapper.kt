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

package com.algorand.android.modules.assets.profile.asaprofile.ui.mapper

import com.algorand.android.models.BaseAccountAddress
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.PeraButtonState
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class AsaStatusPreviewMapper @Inject constructor() {

    fun mapToAsaAccountSelectionStatusPreview(
        statusLabelTextResId: Int,
        actionButtonTextResId: Int,
        peraButtonState: PeraButtonState
    ): AsaStatusPreview.AccountSelectionStatus {
        return AsaStatusPreview.AccountSelectionStatus(
            statusLabelTextResId = statusLabelTextResId,
            peraButtonState = peraButtonState,
            actionButtonTextResId = actionButtonTextResId,
        )
    }

    fun mapToAsaAdditionStatusPreview(
        statusLabelTextResId: Int,
        actionButtonTextResId: Int,
        peraButtonState: PeraButtonState,
        accountAddress: BaseAccountAddress.AccountAddress
    ): AsaStatusPreview.AdditionStatus {
        return AsaStatusPreview.AdditionStatus(
            statusLabelTextResId = statusLabelTextResId,
            peraButtonState = peraButtonState,
            actionButtonTextResId = actionButtonTextResId,
            accountName = accountAddress
        )
    }

    fun mapToAsaRemovalStatusPreview(
        statusLabelTextResId: Int,
        actionButtonTextResId: Int,
        peraButtonState: PeraButtonState,
        formattedAccountBalance: String?,
        assetShortName: AssetName?
    ): AsaStatusPreview.RemovalStatus.AssetRemovalStatus {
        return AsaStatusPreview.RemovalStatus.AssetRemovalStatus(
            statusLabelTextResId = statusLabelTextResId,
            peraButtonState = peraButtonState,
            actionButtonTextResId = actionButtonTextResId,
            formattedAccountBalance = formattedAccountBalance,
            assetShortName = assetShortName
        )
    }

    fun mapToCollectibleRemovalStatusPreview(
        statusLabelTextResId: Int,
        actionButtonTextResId: Int,
        peraButtonState: PeraButtonState,
        accountAddress: BaseAccountAddress.AccountAddress
    ): AsaStatusPreview.RemovalStatus.CollectibleRemovalStatus {
        return AsaStatusPreview.RemovalStatus.CollectibleRemovalStatus(
            statusLabelTextResId = statusLabelTextResId,
            peraButtonState = peraButtonState,
            actionButtonTextResId = actionButtonTextResId,
            accountName = accountAddress
        )
    }

    fun mapToAsaTransferStatusPreview(
        statusLabelTextResId: Int,
        actionButtonTextResId: Int,
        peraButtonState: PeraButtonState,
        formattedAccountBalance: String,
        assetShortName: AssetName?
    ): AsaStatusPreview.TransferStatus {
        return AsaStatusPreview.TransferStatus(
            statusLabelTextResId = statusLabelTextResId,
            peraButtonState = peraButtonState,
            actionButtonTextResId = actionButtonTextResId,
            formattedAccountBalance = formattedAccountBalance,
            assetShortName = assetShortName
        )
    }
}
