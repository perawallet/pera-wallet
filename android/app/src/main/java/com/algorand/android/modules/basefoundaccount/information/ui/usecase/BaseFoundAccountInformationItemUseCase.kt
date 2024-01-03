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

package com.algorand.android.modules.basefoundaccount.information.ui.usecase

import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.basefoundaccount.information.ui.mapoer.BaseFoundAccountInformationItemMapper
import com.algorand.android.modules.basefoundaccount.information.ui.model.BaseFoundAccountInformationItem
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

open class BaseFoundAccountInformationItemUseCase constructor(
    private val baseFoundAccountInformationItemMapper: BaseFoundAccountInformationItemMapper
) {

    protected fun createTitleItem(titleTextResId: Int): BaseFoundAccountInformationItem.TitleItem {
        return baseFoundAccountInformationItemMapper.mapToTitleItem(titleTextResId = titleTextResId)
    }

    protected fun createAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconDrawablePreview: AccountIconDrawablePreview,
        formattedPrimaryValue: String?,
        formattedSecondaryValue: String?
    ): BaseFoundAccountInformationItem.AccountItem {
        return baseFoundAccountInformationItemMapper.mapToAccountItem(
            accountDisplayName = accountDisplayName,
            accountIconDrawablePreview = accountIconDrawablePreview,
            formattedPrimaryValue = formattedPrimaryValue,
            formattedSecondaryValue = formattedSecondaryValue
        )
    }

    protected fun createAssetItem(
        assetId: Long,
        name: AssetName,
        shortName: AssetName,
        verificationTierConfiguration: VerificationTierConfiguration,
        baseAssetDrawableProvider: BaseAssetDrawableProvider,
        formattedPrimaryValue: String?,
        formattedSecondaryValue: String?
    ): BaseFoundAccountInformationItem.AssetItem {
        return baseFoundAccountInformationItemMapper.mapToAssetItem(
            assetId = assetId,
            name = name,
            shortName = shortName,
            verificationTierConfiguration = verificationTierConfiguration,
            baseAssetDrawableProvider = baseAssetDrawableProvider,
            formattedPrimaryValue = formattedPrimaryValue,
            formattedSecondaryValue = formattedSecondaryValue
        )
    }
}
