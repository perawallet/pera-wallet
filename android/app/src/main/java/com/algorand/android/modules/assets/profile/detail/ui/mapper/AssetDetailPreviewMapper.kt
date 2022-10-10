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

package com.algorand.android.modules.assets.profile.detail.ui.mapper

import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.assets.profile.detail.ui.model.AssetDetailPreview
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class AssetDetailPreviewMapper @Inject constructor(
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider
) {

    fun mapToAssetDetailPreview(
        baseOwnedAssetDetail: BaseAccountAssetData.BaseOwnedAssetData,
        accountAddress: String,
        accountName: String,
        accountType: Account.Type?,
        canAccountSignTransaction: Boolean,
        isQuickActionButtonsVisible: Boolean
    ): AssetDetailPreview {
        return with(baseOwnedAssetDetail) {
            AssetDetailPreview(
                assetId = id,
                assetFullName = AssetName.create(name),
                isAlgo = isAlgo,
                formattedPrimaryValue = formattedAmount,
                formattedSecondaryValue = getSelectedCurrencyParityValue().getFormattedValue(),
                accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(accountType),
                accountDisplayName = AccountDisplayName.create(accountAddress, accountName, accountType),
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                assetPrismUrl = prismUrl,
                verificationTierConfiguration =
                verificationTierConfigurationDecider.decideVerificationTierConfiguration(verificationTier),
                isQuickActionButtonsVisible = canAccountSignTransaction && isQuickActionButtonsVisible
            )
        }
    }
}
