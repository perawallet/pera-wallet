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

package com.algorand.android.usecase

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.accounts.domain.mapper.AccountValueMapper
import com.algorand.android.modules.accounts.domain.model.AccountValue
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class GetAccountTotalCollectibleValueUseCase @Inject constructor(
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val accountValueMapper: AccountValueMapper
) {

    fun getAccountTotalCollectibleValueFlow(accountAddress: String): Flow<AccountValue> {
        return accountCollectibleDataUseCase.getAccountOwnedCollectibleDataFlow(accountAddress).map {
            getAccountTotalCollectibleValue(it)
        }
    }

    private fun getAccountTotalCollectibleValue(
        accountOwnedCollectibleList: List<BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData>
    ): AccountValue {
        var collectiblePrimaryAccountValue = BigDecimal.ZERO
        var collectibleSecondaryAccountValue = BigDecimal.ZERO
        var totalCollectibleCount = 0
        accountOwnedCollectibleList.forEach {
            collectiblePrimaryAccountValue += it.parityValueInSelectedCurrency.amountAsCurrency
            collectibleSecondaryAccountValue += it.parityValueInSelectedCurrency.amountAsCurrency
            totalCollectibleCount++
        }
        return accountValueMapper.mapTo(
            primaryAccountValue = collectiblePrimaryAccountValue,
            secondaryAccountValue = collectibleSecondaryAccountValue,
            assetCount = totalCollectibleCount
        )
    }
}
