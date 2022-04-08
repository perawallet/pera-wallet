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

package com.algorand.android.nft.utils

import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.isGreaterThan
import java.math.BigInteger
import javax.inject.Inject

class CollectibleUtils @Inject constructor() {

    fun isCollectibleOwnedByTheUser(accountDetail: CacheResult<AccountDetail>?, collectibleAssetId: Long): Boolean {
        val assetHolding = accountDetail?.data?.accountInformation?.assetHoldingList?.firstOrNull {
            it.assetId == collectibleAssetId
        } ?: return false
        return assetHolding.amount isGreaterThan BigInteger.ZERO
    }

    fun isCollectibleOwnedByTheWatchAccount(
        accountDetail: CacheResult<AccountDetail>?,
        collectibleAssetId: Long
    ): Boolean {
        accountDetail?.data?.accountInformation?.assetHoldingList?.firstOrNull {
            it.assetId == collectibleAssetId
        } ?: return false
        return true
    }

    fun isCollectibleOwnedByTheUser(accountDetail: AccountDetail, collectibleAssetId: Long): Boolean {
        val assetHolding = accountDetail.accountInformation.assetHoldingList.firstOrNull {
            it.assetId == collectibleAssetId
        } ?: return false
        return assetHolding.amount isGreaterThan BigInteger.ZERO
    }

    private fun isCollectibleOptedInByTheUser(
        accountDetail: CacheResult<AccountDetail>?,
        collectibleAssetId: Long
    ): Boolean {
        accountDetail?.data?.accountInformation?.assetHoldingList?.firstOrNull {
            it.assetId == collectibleAssetId
        } ?: return false
        return true
    }

    fun isCollectibleOwnedByAnyUser(
        accountDetailList: Collection<CacheResult<AccountDetail>?>,
        assetId: Long
    ): Boolean {
        return accountDetailList.any { isCollectibleOwnedByTheUser(it, assetId) }
    }

    fun isCollectibleOptedInByAnyUser(
        accountDetailList: Collection<CacheResult<AccountDetail>?>,
        assetId: Long
    ): Boolean {
        return accountDetailList.any { isCollectibleOptedInByTheUser(it, assetId) }
    }

    fun isBeingHoldByWatchAccount(
        accountDetailList: Collection<CacheResult<AccountDetail>?>,
        collectibleAssetId: Long
    ): Boolean {
        val watchAccounts = accountDetailList.filter { it?.data?.account?.type == Account.Type.WATCH }
        return watchAccounts.any { isCollectibleOwnedByTheWatchAccount(it, collectibleAssetId) }
    }

    fun getCollectibleOwnerAccountOrNull(
        accountDetailList: Collection<CacheResult<AccountDetail>>,
        collectibleAssetId: Long,
        publicKey: String
    ): Account? {
        val selectedAccount = accountDetailList.firstOrNull { it.data?.account?.address == publicKey }
        val isCollectibleOwnedBySelectedAccount = selectedAccount
            ?.data?.accountInformation?.assetHoldingList
            ?.any { it.assetId == collectibleAssetId } ?: false
        return selectedAccount?.data?.account.takeIf { isCollectibleOwnedBySelectedAccount }
    }
}
