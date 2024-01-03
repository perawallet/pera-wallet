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

package com.algorand.android.modules.accounts.domain.mapper

import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.BaseAccountItem.AccountErrorItem
import com.algorand.android.modules.accounts.domain.model.BaseAccountListItem.BaseAccountItem.AccountItem
import javax.inject.Inject

class AccountListItemMapper @Inject constructor() {

    fun mapToErrorAccountItem(
        accountListItem: BaseAccountAndAssetListItem.AccountListItem,
        canCopyable: Boolean
    ): AccountErrorItem {
        return AccountErrorItem(accountListItem, canCopyable)
    }

    fun mapToAccountItem(
        accountListItem: BaseAccountAndAssetListItem.AccountListItem,
        canCopyable: Boolean
    ): AccountItem {
        return AccountItem(accountListItem, canCopyable)
    }

    fun mapToQuickActionsItem(isSwapButtonSelected: Boolean): BaseAccountListItem.QuickActionsItem {
        return BaseAccountListItem.QuickActionsItem(isSwapButtonSelected = isSwapButtonSelected)
    }
}
