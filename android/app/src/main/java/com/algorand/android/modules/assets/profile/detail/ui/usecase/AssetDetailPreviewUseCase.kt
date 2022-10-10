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

package com.algorand.android.modules.assets.profile.detail.ui.usecase

import com.algorand.android.modules.assets.profile.detail.domain.usecase.GetAccountAssetDetailUseCase
import com.algorand.android.modules.assets.profile.detail.ui.mapper.AssetDetailPreviewMapper
import com.algorand.android.modules.assets.profile.detail.ui.model.AssetDetailPreview
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filterNotNull

class AssetDetailPreviewUseCase @Inject constructor(
    private val getAccountAssetDetailUseCase: GetAccountAssetDetailUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailPreviewMapper: AssetDetailPreviewMapper
) {

    suspend fun initAssetDetailPreview(
        accountAddress: String,
        assetId: Long,
        isQuickActionButtonsVisible: Boolean
    ): Flow<AssetDetailPreview> {
        return combine(
            getAccountAssetDetailUseCase.getAssetDetail(accountAddress, assetId).filterNotNull(),
            accountDetailUseCase.getAccountDetailCacheFlow(accountAddress).filterNotNull()
        ) { baseOwnedAssetDetail, cachedAccountDetail ->
            val account = cachedAccountDetail.data?.account
            assetDetailPreviewMapper.mapToAssetDetailPreview(
                baseOwnedAssetDetail = baseOwnedAssetDetail,
                accountAddress = accountAddress,
                accountName = account?.name.orEmpty(),
                accountType = account?.type,
                canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(accountAddress),
                isQuickActionButtonsVisible = isQuickActionButtonsVisible
            )
        }.distinctUntilChanged()
    }
}
