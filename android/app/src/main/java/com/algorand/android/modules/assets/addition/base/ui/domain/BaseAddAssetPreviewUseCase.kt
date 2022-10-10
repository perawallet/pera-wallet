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

package com.algorand.android.modules.assets.addition.base.ui.domain

import androidx.paging.CombinedLoadStates
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.modules.assets.addition.base.ui.mapper.BaseAddAssetTransactionResultPreviewMapper
import com.algorand.android.modules.assets.addition.base.ui.model.BaseAddAssetTransactionResultPreview
import com.algorand.android.modules.assets.addition.ui.model.AssetAdditionType
import com.algorand.android.usecase.AssetAdditionUseCase
import javax.inject.Inject

class BaseAddAssetPreviewUseCase @Inject constructor(
    private val baseAddAssetTransactionResultPreviewMapper: BaseAddAssetTransactionResultPreviewMapper,
    private val assetAdditionUseCase: AssetAdditionUseCase
) {

    fun getInitialAddAssetTransactionResultPreview(): BaseAddAssetTransactionResultPreview {
        return baseAddAssetTransactionResultPreviewMapper.mapToBaseAddAssetTransactionResultPreview(
            onTransactionLoading = null,
            onTransactionFailed = null,
            onTransactionSuccess = null
        )
    }

    fun createAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean,
        assetAdditionType: AssetAdditionType
    ): AssetAdditionLoadStatePreview {
        return assetAdditionUseCase.createAssetAdditionLoadStatePreview(
            combinedLoadStates = combinedLoadStates,
            itemCount = itemCount,
            isLastStateError = isLastStateError,
            assetAdditionType = assetAdditionType
        )
    }
}
