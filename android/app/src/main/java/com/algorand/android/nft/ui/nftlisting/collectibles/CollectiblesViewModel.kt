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

package com.algorand.android.nft.ui.nftlisting.collectibles

import com.algorand.android.modules.tracking.nft.CollectibleEventTracker
import com.algorand.android.nft.domain.usecase.CollectiblesListingPreviewUseCase
import com.algorand.android.nft.ui.base.BaseCollectibleListingViewModel
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.sharedpref.SharedPrefLocalSource
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged

@HiltViewModel
class CollectiblesViewModel @Inject constructor(
    private val collectiblesListingPreviewUseCase: CollectiblesListingPreviewUseCase,
    collectibleEventTracker: CollectibleEventTracker
) : BaseCollectibleListingViewModel(collectiblesListingPreviewUseCase, collectibleEventTracker) {

    override val nftListingViewTypeChangeListener = SharedPrefLocalSource.OnChangeListener<Int> {
        startCollectibleListingPreviewFlow()
    }

    init {
        collectiblesListingPreviewUseCase.addOnListingViewTypeChangeListener(nftListingViewTypeChangeListener)
    }

    override suspend fun initCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview> {
        return collectiblesListingPreviewUseCase.getCollectiblesListingPreviewFlow(searchKeyword).distinctUntilChanged()
    }

    override fun onCleared() {
        collectiblesListingPreviewUseCase.removeOnListingViewTypeChangeListener(nftListingViewTypeChangeListener)
        super.onCleared()
    }
}
