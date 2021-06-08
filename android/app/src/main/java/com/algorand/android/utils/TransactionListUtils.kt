/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils

import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.TransactionImpl
import com.algorand.android.models.User

fun List<TransactionImpl>.toListItems(
    assetId: Long,
    decimals: Int,
    accountPublicKey: String,
    accountList: List<Account>,
    contactList: List<User>,
    isRewardsIncluded: Boolean = false
): MutableList<BaseTransactionListItem> {
    val result = mutableListOf<BaseTransactionListItem>()
    if (isEmpty()) {
        return result
    }
    forEach { transaction ->
        if (transaction.includeInHistory(assetId)) {
            result.add(transaction.toTransactionListItem(assetId, accountPublicKey, contactList, accountList, decimals))

            if (isRewardsIncluded && assetId == AssetInformation.ALGORAND_ID) {
                val rewardOfTransaction = transaction.getRewardOfTransaction(accountPublicKey)
                if (rewardOfTransaction != null) {
                    result.add(rewardOfTransaction)
                }
            }
        }
    }

    return result
}

fun getUserIfSavedLocally(
    contactList: List<User>,
    accountList: List<Account>,
    nonOwnerPublicKey: String?
): User? {
    if (nonOwnerPublicKey == null) {
        return null
    }

    val foundContact = contactList.firstOrNull { it.publicKey == nonOwnerPublicKey }
    if (foundContact != null) {
        return foundContact
    }

    val foundAccount = accountList.firstOrNull { it.address == nonOwnerPublicKey }
    if (foundAccount != null) {
        return User(foundAccount.name, foundAccount.address, null, -1)
    }

    return null
}
