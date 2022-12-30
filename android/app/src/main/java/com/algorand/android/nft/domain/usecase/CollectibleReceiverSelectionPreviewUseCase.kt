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
import com.algorand.android.nft.ui.model.CollectibleReceiverSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import com.algorand.android.utils.isValidAddress
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow

class CollectibleReceiverSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val collectibleReceiverSelectionPreviewMapper: CollectibleReceiverSelectionPreviewMapper
) {

    fun getCollectibleReceiverSelectionPreview(
        query: String,
        copiedMessage: String?
    ): Flow<CollectibleReceiverSelectionPreview> {
        val accountItems = createAccountItems(query)
        val contactItems = createContactItems(query)
        val nftDomainItems = createNftDomainItems(query)
        val queriedAddress = query.takeIf { it.isValidAddress() }
        return combine(
            accountItems,
            contactItems,
            nftDomainItems
        ) { accounts, contacts, nftDomains ->
            val accountSelectionItems = mutableListOf<BaseAccountSelectionListItem>().apply {
                createPasteItem(copiedMessage)?.run { add(this) }
                createQueriedAccountItem(
                    accountAddresses = accounts.map { it.publicKey },
                    contactAddresses = contacts.map { it.publicKey },
                    queriedAddress = queriedAddress
                )?.run {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.account))
                    add(this)
                }
                if (contacts.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.contacts))
                    addAll(contacts)
                }
                if (accounts.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.my_accounts))
                    addAll(accounts)
                }
                if (nftDomains.isNotEmpty()) {
                    add(BaseAccountSelectionListItem.HeaderItem(R.string.matched_accounts))
                    addAll(nftDomains)
                }
            }
            collectibleReceiverSelectionPreviewMapper.mapTo(accountSelectionItems)
        }.distinctUntilChanged()
    }

    private fun createPasteItem(latestCopiedMessage: String?): BaseAccountSelectionListItem.PasteItem? {
        return latestCopiedMessage.takeIf { it.isValidAddress() }?.let { copiedAccount ->
            BaseAccountSelectionListItem.PasteItem(copiedAccount)
        }
    }

    private fun createQueriedAccountItem(
        queriedAddress: String?,
        accountAddresses: List<String>,
        contactAddresses: List<String>
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountItem? {
        if (queriedAddress.isNullOrBlank()) return null
        val shouldInsertQueriedAccount = shouldInsertQueriedAccount(
            accountAddresses = accountAddresses,
            contactAddresses = contactAddresses,
            queriedAccount = queriedAddress
        )
        if (!shouldInsertQueriedAccount) return null
        return accountSelectionListUseCase.createAccountSelectionItemFromAccountAddress(
            accountAddress = queriedAddress
        )
    }

    private fun shouldInsertQueriedAccount(
        accountAddresses: List<String>,
        contactAddresses: List<String>,
        queriedAccount: String?
    ): Boolean {
        return !accountAddresses.contains(queriedAccount) && !contactAddresses.contains(queriedAccount)
    }

    private fun createContactItems(query: String) = flow {
        val contactListItems = accountSelectionListUseCase.createAccountSelectionListContactItems().filter {
            it.displayName.contains(query, true) || it.publicKey.contains(query, true)
        }
        emit(contactListItems)
    }

    private fun createAccountItems(query: String) = flow {
        val accountListItems = accountSelectionListUseCase.createAccountSelectionListAccountItems(
            showHoldings = false,
            shouldIncludeWatchAccounts = true,
            showFailedAccounts = true
        ).filter { it.displayName.contains(query, true) || it.publicKey.contains(query, true) }
        emit(accountListItems)
    }

    private fun createNftDomainItems(query: String) = flow {
        val nftDomainListItems = accountSelectionListUseCase.createAccountSelectionNftDomainItems(query)
        emit(nftDomainListItems)
    }
}
