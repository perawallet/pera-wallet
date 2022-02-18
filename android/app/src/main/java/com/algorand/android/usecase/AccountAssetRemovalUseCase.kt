/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AssetStatus
import com.algorand.android.utils.CacheResult
import javax.inject.Inject

class AccountAssetRemovalUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase
) : BaseUseCase() {

    fun getAccountSummary(publicKey: String): AccountDetailSummary? {
        return accountDetailUseCase.getAccountSummary(publicKey)
    }

    suspend fun addAssetDeletionToAccountCache(publicKey: String, assetId: Long) {
        val cachedAccountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data ?: return
        cachedAccountDetail.accountInformation.setAssetHoldingStatus(assetId, AssetStatus.PENDING_FOR_REMOVAL)
        accountDetailUseCase.cacheAccountDetail(CacheResult.Success.create(cachedAccountDetail))
    }
}
