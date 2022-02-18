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

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.BaseAccountItem.AccountErrorItem
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.BaseAccountItem.AccountItem
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.BasePortfolioValueItem.PortfolioValuesErrorItem
import javax.inject.Inject

class AccountListItemMapper @Inject constructor() {

    fun mapToErrorAccountItem(account: Account, isErrorIconVisible: Boolean): AccountErrorItem {
        return AccountErrorItem(
            displayName = account.name.takeIf { it.isNotBlank() } ?: account.address,
            publicKey = account.address,
            accountIcon = account.createAccountIcon(),
            isErrorIconVisible = isErrorIconVisible
        )
    }

    fun mapToAccountItem(accountDetail: AccountDetail, formattedHoldings: String, assetCount: Int): AccountItem {
        return with(accountDetail) {
            AccountItem(
                displayName = account.name.takeIf { it.isNotBlank() } ?: account.address,
                publicKey = account.address,
                formattedHoldings = formattedHoldings,
                assetCount = assetCount,
                accountIcon = account.createAccountIcon(),
            )
        }
    }

    fun mapToPortfolioValuesSuccessItem(
        formattedPortfolioValue: String,
        formattedAlgoHoldings: String,
        formattedAssetHoldings: String
    ): BaseAccountListItem.BasePortfolioValueItem.PortfolioValuesItem {
        return BaseAccountListItem.BasePortfolioValueItem.PortfolioValuesItem(
            formattedPortfolioValue = formattedPortfolioValue,
            formattedAlgoHoldings = formattedAlgoHoldings,
            formattedAssetHoldings = formattedAssetHoldings
        )
    }

    fun mapToPortfolioValuesPartialErrorItem(): PortfolioValuesErrorItem {
        return PortfolioValuesErrorItem(titleColorResId = R.color.errorTextColor)
    }

    fun mapToPortfolioValuesInitializationErrorItem(): PortfolioValuesErrorItem {
        return PortfolioValuesErrorItem(titleColorResId = R.color.errorTextColor)
    }
}
