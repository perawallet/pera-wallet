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

package com.algorand.android.usecase

import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject

class CoreCacheUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val blockPollingUseCase: BlockPollingUseCase,
    private val bannersUseCase: BannersUseCase
) {

    suspend fun handleNodeChange() {
        accountCacheManager.removeCachedData()
        blockPollingUseCase.clearBlockCache()
        accountDetailUseCase.clearAccountDetailCache()
        assetDetailUseCase.clearAssetDetailCache()
        bannersUseCase.clearBannerCache()
    }

    suspend fun clearAllCachedData() {
        accountCacheManager.removeCachedData()
        accountDetailUseCase.clearAccountDetailCache()
        assetDetailUseCase.clearAssetDetailCache()
        bannersUseCase.clearBannerCache()
    }
}
