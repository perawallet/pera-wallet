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

import com.algorand.android.modules.accounts.domain.model.AccountValue
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.mapNotNull

class GetAccountTotalAssetValueUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getAccountValueUseCase: GetAccountValueUseCase
) {

    fun getAccountTotalAssetValueFlow(accountAddress: String): Flow<AccountValue> {
        return accountDetailUseCase.getAccountDetailCacheFlow(accountAddress).mapNotNull { accountDetail ->
            accountDetail?.data?.let { getAccountValueUseCase.getAccountValue(it) }
        }
    }
}
