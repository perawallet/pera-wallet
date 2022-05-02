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

package com.algorand.android.mapper

import androidx.paging.CombinedLoadStates
import androidx.paging.LoadState
import com.algorand.android.decider.AssetAdditionScreenStateViewTypeDecider
import com.algorand.android.decider.AssetAdditionScreenStateViewVisibilityDecider
import com.algorand.android.models.ui.AssetAdditionLoadStatePreview
import com.algorand.android.ui.addasset.AssetAdditionType
import javax.inject.Inject

class AssetAdditionLoadStatePreviewMapper @Inject constructor(
    private val assetAdditionScreenStateViewVisibilityDecider: AssetAdditionScreenStateViewVisibilityDecider,
    private val assetAdditionScreenStateViewTypeDecider: AssetAdditionScreenStateViewTypeDecider,
) {

    fun mapToAssetAdditionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean,
        assetAdditionType: AssetAdditionType
    ): AssetAdditionLoadStatePreview {
        return AssetAdditionLoadStatePreview(
            isAssetListVisible = (combinedLoadStates.refresh is LoadState.Error).not() &&
                (isLastStateError && combinedLoadStates.refresh is LoadState.Loading).not(),
            isScreenStateViewVisible = assetAdditionScreenStateViewVisibilityDecider.decideScreenStateViewVisibility(
                combinedLoadStates,
                itemCount,
            ),
            screenStateViewType = assetAdditionScreenStateViewTypeDecider.decideScreenStateViewType(
                combinedLoadStates = combinedLoadStates,
                itemCount = itemCount,
                assetAdditionType = assetAdditionType
            ),
            isLoading = (combinedLoadStates.refresh is LoadState.Loading) ||
                (combinedLoadStates.append is LoadState.Loading)
        )
    }
}
