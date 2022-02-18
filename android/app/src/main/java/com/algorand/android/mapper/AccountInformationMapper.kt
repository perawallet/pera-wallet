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

import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountInformationResponsePayload
import com.algorand.android.models.Participation
import java.math.BigInteger
import javax.inject.Inject

class AccountInformationMapper @Inject constructor(
    private val assetHoldingsMapper: AssetHoldingsMapper
) {

    fun mapToAccountInformation(accountInformationPayload: AccountInformationResponsePayload): AccountInformation {
        val assetHoldingList = accountInformationPayload.allAssetHoldingList
            ?.map { assetHoldingsMapper.mapToAssetHoldings(it) }
            ?.toMutableSet()
        return AccountInformation(
            address = accountInformationPayload.address.orEmpty(),
            amount = accountInformationPayload.amount ?: BigInteger.ZERO,
            rewards = accountInformationPayload.rewards ?: 0L,
            pendingRewards = accountInformationPayload.pendingRewards ?: 0L,
            participation = accountInformationPayload.participation,
            rekeyAdminAddress = accountInformationPayload.rekeyAdminAddress,
            allAssetHoldingList = assetHoldingList,
            createdAtRound = accountInformationPayload.createdAtRound,
            amountWithoutPendingRewards = accountInformationPayload.amountWithoutPendingRewards ?: BigInteger.ZERO,
            createdApps = accountInformationPayload.createdApps,
            appsLocalState = accountInformationPayload.appsLocalState,
            appsTotalSchema = accountInformationPayload.appsTotalSchema,
            appsTotalExtraPages = accountInformationPayload.appsTotalExtraPages
        )
    }

    fun createEmptyAccountInformation(accountPublicKey: String): AccountInformation {
        return AccountInformation(
            address = accountPublicKey,
            amount = BigInteger.ZERO,
            rewards = 0L,
            pendingRewards = 0L,
            participation = Participation(),
            rekeyAdminAddress = null,
            allAssetHoldingList = mutableSetOf(),
            createdAtRound = null,
            amountWithoutPendingRewards = BigInteger.ZERO
        )
    }
}
