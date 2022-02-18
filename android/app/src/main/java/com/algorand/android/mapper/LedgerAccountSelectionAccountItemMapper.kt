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

package com.algorand.android.mapper

import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class LedgerAccountSelectionAccountItemMapper @Inject constructor() {

    fun mapTo(
        accountInformation: AccountInformation,
        accountDetail: Account.Detail,
        accountCacheManager: AccountCacheManager
    ): AccountSelectionListItem.AccountItem {
        with(accountInformation) {
            return AccountSelectionListItem.AccountItem(
                assetInformationList = getAssetInformationList(accountCacheManager),
                account = Account.create(address, accountDetail, address.toShortenedAddress()),
                accountInformation = this
            )
        }
    }
}
