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
 */

package com.algorand.android.usecase

import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.mapper.AccountSelectionListItemMapper
import com.algorand.android.mapper.BaseAccountAndAssetListItemMapper
import com.algorand.android.models.Account.Companion.defaultAccountType
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import javax.inject.Inject

class CreateAccountSelectionAccountItemUseCase @Inject constructor(
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val accountSelectionListItemMapper: AccountSelectionListItemMapper,
    private val baseAccountAndAssetListItemMapper: BaseAccountAndAssetListItemMapper,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase
) {

    fun createAccountSelectionAccountItemFromAccountAddress(
        accountAddress: String
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountItem {
        val accountType = defaultAccountType
        val accountItemConfiguration = accountItemConfigurationMapper.mapTo(
            accountAddress = accountAddress,
            accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(accountType),
            accountType = accountType,
            accountDisplayName = accountDisplayNameUseCase.invoke(accountAddress)
        )
        val accountListItem = baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
        return accountSelectionListItemMapper.mapToAccountItem(accountListItem)
    }
}
