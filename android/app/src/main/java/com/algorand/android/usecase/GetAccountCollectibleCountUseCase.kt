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

import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import javax.inject.Inject

class GetAccountCollectibleCountUseCase @Inject constructor(
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun getAccountCollectibleCount(publicKey: String): Int {
        val cachedCollectibles = simpleCollectibleUseCase.getCachedCollectibleList().mapNotNull { it.value.data }
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data
        val accountHoldings = accountDetail?.accountInformation?.assetHoldingList
        var collectibleCount = 0
        accountHoldings?.forEach { assetHolding ->
            if (cachedCollectibles.firstOrNull { it.assetId == assetHolding.assetId } != null) collectibleCount++
        }
        return collectibleCount
    }
}
