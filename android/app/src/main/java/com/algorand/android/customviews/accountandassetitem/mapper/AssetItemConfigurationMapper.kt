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

package com.algorand.android.customviews.accountandassetitem.mapper

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.customviews.accountandassetitem.model.BaseItemConfiguration
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.AssetName
import java.math.BigDecimal
import javax.inject.Inject

class AssetItemConfigurationMapper @Inject constructor(
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider
) {

    fun mapTo(
        isAmountInSelectedCurrencyVisible: Boolean,
        secondaryValueText: String,
        assetId: Long,
        name: String?,
        shortName: String?,
        formattedCompactAmount: String,
        verificationTier: VerificationTier,
        primaryValue: BigDecimal?
    ): BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration {
        return BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration(
            assetId = assetId,
            assetIconDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(assetId),
            primaryAssetName = AssetName.create(name),
            secondaryAssetName = AssetName.createShortName(shortName),
            primaryValueText = formattedCompactAmount,
            secondaryValueText = secondaryValueText.takeIf { isAmountInSelectedCurrencyVisible },
            verificationTierConfiguration = verificationTierConfigurationDecider.decideVerificationTierConfiguration(
                verificationTier
            ),
            primaryValue = primaryValue
        )
    }

    fun mapTo(
        assetId: Long,
        assetFullName: AssetName,
        assetShortName: AssetName,
        showWithAssetId: Boolean,
        verificationTierConfiguration: VerificationTierConfiguration
    ): BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration {
        return BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration(
            assetId = assetId,
            assetIconDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(assetId),
            primaryAssetName = assetFullName,
            secondaryAssetName = assetShortName,
            showWithAssetId = showWithAssetId,
            verificationTierConfiguration = verificationTierConfiguration
        )
    }
}
