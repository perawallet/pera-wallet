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

package com.algorand.android.modules.accounts.domain.usecase

import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.models.Account
import com.algorand.android.usecase.GetCachedAccountDetailUseCase
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class AccountDisplayNameUseCase @Inject constructor(
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val getCachedAccountDetailUseCase: GetCachedAccountDetailUseCase
) {

    operator fun invoke(accountAddress: String): AccountDisplayName {
        val accountDetail = getCachedAccountDetailUseCase.invoke(accountAddress)?.data
        return accountDisplayNameMapper.mapToAccountDisplayName(
            accountAddress = accountAddress,
            accountName = accountDetail?.account?.name.orEmpty().ifBlank { accountAddress.toShortenedAddress() },
            nfDomainName = accountDetail?.nameServiceName,
            type = accountDetail?.account?.type ?: Account.defaultAccountType
        )
    }
}
