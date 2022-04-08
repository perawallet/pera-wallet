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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.R
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.nft.mapper.CollectibleReceiverSelectionPreviewMapper
import com.algorand.android.usecase.AccountSelectionListUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class CollectibleReceiverSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val collectibleReceiverSelectionPreviewMapper: CollectibleReceiverSelectionPreviewMapper
) {

    suspend fun getCollectibleReceiverSelectionPreview(
        query: String
    ) = flow {
        emit(collectibleReceiverSelectionPreviewMapper.mapToLoading())
        val accountItems = accountSelectionListUseCase.createAccountSelectionListAccountItems(
            showAssetCount = false,
            showHoldings = false,
            shouldIncludeWatchAccounts = true,
            showFailedAccounts = true
        ).filter { it.displayName.contains(query, true) || it.publicKey.contains(query, true) }

        val contactItems = accountSelectionListUseCase.createAccountSelectionListContactItems().filter {
            it.displayName.contains(query, true) || it.publicKey.contains(query, true)
        }

        val accountSelectionItems = mutableListOf<BaseAccountSelectionListItem>().apply {
            if (contactItems.isNotEmpty()) {
                add(BaseAccountSelectionListItem.HeaderItem(R.string.contacts))
                addAll(contactItems)
            }
            if (accountItems.isNotEmpty()) {
                add(BaseAccountSelectionListItem.HeaderItem(R.string.my_accounts))
                addAll(accountItems)
            }
        }
        emit(collectibleReceiverSelectionPreviewMapper.mapTo(accountSelectionItems))
    }
}
