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

import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaProfilePreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaStatusPreview
import com.algorand.android.modules.assets.profile.detail.ui.mapper.AssetDetailMarketInformationDecider
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import java.math.BigDecimal
import javax.inject.Inject

class AsaProfilePreviewMapper @Inject constructor(
    private val assetDetailMarketInformationDecider: AssetDetailMarketInformationDecider
) {

    @SuppressWarnings("LongParameterList")
    fun mapToAsaProfilePreview(
        isAlgo: Boolean,
        assetFullName: String?,
        assetShortName: String?,
        assetId: Long,
        formattedAssetPrice: String?,
        verificationTierConfiguration: VerificationTierConfiguration,
        baseAssetDrawableProvider: BaseAssetDrawableProvider,
        assetPrismUrl: String?,
        asaStatusPreview: AsaStatusPreview?,
        isMarketInformationVisible: Boolean,
        last24HoursChange: BigDecimal?
    ): AsaProfilePreview {
        return AsaProfilePreview(
            isAlgo = isAlgo,
            assetFullName = AssetName.create(assetFullName),
            assetShortName = AssetName.createShortName(assetShortName),
            assetId = assetId,
            formattedAssetPrice = formattedAssetPrice,
            verificationTierConfiguration = verificationTierConfiguration,
            baseAssetDrawableProvider = baseAssetDrawableProvider,
            assetPrismUrl = assetPrismUrl,
            asaStatusPreview = asaStatusPreview,
            isMarketInformationVisible = isMarketInformationVisible,
            isChangePercentageVisible = assetDetailMarketInformationDecider.decideIsChangePercentageVisible(
                last24HoursChange
            ),
            changePercentage = last24HoursChange,
            changePercentageIcon = assetDetailMarketInformationDecider.decideIconResOfChangePercentage(
                last24HoursChange
            ),
            changePercentageTextColor = assetDetailMarketInformationDecider.decideTextColorResOfChangePercentage(
                last24HoursChange
            )
        )
    }
}
