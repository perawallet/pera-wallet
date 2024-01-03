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

package com.algorand.android.mapper

import android.net.Uri
import com.algorand.android.decider.AccountDisplayNameDecider
import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.modules.nftdomain.domain.model.NftDomainSearchResult
import javax.inject.Inject

class AccountSelectionListItemMapper @Inject constructor(
    private val accountDisplayNameDecider: AccountDisplayNameDecider
) {

    fun mapToErrorAccountItem(
        accountListItem: BaseAccountAndAssetListItem.AccountListItem
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountErrorItem {
        return BaseAccountSelectionListItem.BaseAccountItem.AccountErrorItem(accountListItem = accountListItem)
    }

    fun mapToAccountItem(
        accountListItem: BaseAccountAndAssetListItem.AccountListItem
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountItem {
        return BaseAccountSelectionListItem.BaseAccountItem.AccountItem(accountListItem = accountListItem)
    }

    fun mapToContactItem(
        name: String,
        publicKey: String,
        imageUri: Uri?
    ): BaseAccountSelectionListItem.BaseAccountItem.ContactItem {
        return BaseAccountSelectionListItem.BaseAccountItem.ContactItem(
            displayName = accountDisplayNameDecider.decideDisplayName(name, publicKey),
            publicKey = publicKey,
            imageUri = imageUri
        )
    }

    fun mapToNftDomainAccountItem(
        nftDomainSearchResult: NftDomainSearchResult
    ): BaseAccountSelectionListItem.BaseAccountItem.NftDomainAccountItem {
        return BaseAccountSelectionListItem.BaseAccountItem.NftDomainAccountItem(
            displayName = nftDomainSearchResult.name,
            publicKey = nftDomainSearchResult.accountAddress,
            serviceLogoUrl = nftDomainSearchResult.service?.logoUrl
        )
    }
}
