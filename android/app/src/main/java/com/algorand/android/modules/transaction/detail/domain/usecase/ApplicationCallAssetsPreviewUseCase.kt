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

package com.algorand.android.modules.transaction.detail.domain.usecase

import com.algorand.android.customviews.accountandassetitem.mapper.AssetItemConfigurationMapper
import com.algorand.android.modules.transaction.detail.domain.model.ApplicationCallAssetInformationPreview
import com.algorand.android.modules.transaction.detail.ui.mapper.ApplicationCallAssetInformationPreviewMapper
import com.algorand.android.modules.transaction.detail.ui.mapper.BaseApplicationCallAssetInformationListItemMapper
import com.algorand.android.modules.transaction.detail.ui.model.ApplicationCallAssetInformation
import javax.inject.Inject

class ApplicationCallAssetsPreviewUseCase @Inject constructor(
    private val assetItemConfigurationMapper: AssetItemConfigurationMapper,
    private val applicationCallAssetInformationPreviewMapper: ApplicationCallAssetInformationPreviewMapper,
    private val baseApplicationCallAssetInformationListItemMapper: BaseApplicationCallAssetInformationListItemMapper
) {

    fun initApplicationCallAssetInformationPreview(
        applicationCallAssetInformationArray: Array<ApplicationCallAssetInformation>
    ): ApplicationCallAssetInformationPreview {
        val assetInformationItemList = applicationCallAssetInformationArray.map {
            val assetItemConfiguration = assetItemConfigurationMapper.mapTo(
                assetId = it.assetId,
                assetFullName = it.assetFullName,
                assetShortName = it.assetShortName,
                showWithAssetId = true,
                verificationTierConfiguration = it.verificationTierConfiguration
            )
            baseApplicationCallAssetInformationListItemMapper.mapToAssetInformationItem(assetItemConfiguration)
        }
        return applicationCallAssetInformationPreviewMapper.mapToApplicationCallAssetInformationPreview(
            applicationCallAssetInformationListItems = assetInformationItemList
        )
    }
}
