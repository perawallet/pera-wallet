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

package com.algorand.android.modules.assets.addition.base.ui

import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.modules.assets.addition.base.ui.domain.BaseAddAssetPreviewUseCase
import com.algorand.android.modules.assets.addition.ui.model.AssetAdditionType
import kotlinx.coroutines.flow.Flow

abstract class BaseAddAssetViewModel(
    private val baseAddAssetPreviewUseCase: BaseAddAssetPreviewUseCase
) : BaseViewModel() {

    protected abstract val searchPaginationFlow: Flow<PagingData<BaseAssetSearchListItem>>

    protected val assetSearchPagerBuilder = AssetSearchPagerBuilder.create()

    val assetSearchPaginationFlow
        get() = searchPaginationFlow

    fun createAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean,
        assetAdditionType: AssetAdditionType
    ): AssetAdditionLoadStatePreview {
        return baseAddAssetPreviewUseCase.createAssetAdditionLoadStatePreview(
            combinedLoadStates = combinedLoadStates,
            itemCount = itemCount,
            isLastStateError = isLastStateError,
            assetAdditionType = assetAdditionType
        )
    }

    companion object {
        const val SEARCH_RESULT_LIMIT = 50
    }
}
