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

package com.algorand.android.ui.accountdetail.nfts

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import com.algorand.android.nft.domain.usecase.AccountCollectiblesListingPreviewUseCase
import com.algorand.android.nft.ui.base.BaseCollectibleListingViewModel
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.ui.accountdetail.nfts.AccountCollectiblesFragment.Companion.PUBLIC_KEY
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged

class AccountCollectiblesViewModel @ViewModelInject constructor(
    private val collectiblesPreviewUseCase: AccountCollectiblesListingPreviewUseCase,
    @Assisted private val savedStateHandle: SavedStateHandle
) : BaseCollectibleListingViewModel(collectiblesPreviewUseCase) {

    private val accountPublicKey: String
        get() = savedStateHandle.getOrThrow(PUBLIC_KEY)

    override fun initCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview> {
        return collectiblesPreviewUseCase
            .getCollectiblesListingPreviewFlow(searchKeyword, accountPublicKey)
            .distinctUntilChanged()
    }
}
