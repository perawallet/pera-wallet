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

package com.algorand.android.modules.accounts.domain.usecase

import com.algorand.android.modules.accounts.domain.model.AccountValue
import com.algorand.android.models.AccountDetail
import com.algorand.android.modules.accounts.domain.mapper.AccountValueMapper
import com.algorand.android.usecase.AccountAssetDataUseCase
import java.math.BigDecimal
import javax.inject.Inject

class GetAccountValueUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountValueMapper: AccountValueMapper
) {

    fun getAccountValue(account: AccountDetail): AccountValue {
        var primaryAccountValue = BigDecimal.ZERO
        var secondaryAccountValue = BigDecimal.ZERO
        var assetCount = 0
        accountAssetDataUseCase.getNonCachedAccountAssetData(account, true).forEach {
            primaryAccountValue += it.parityValueInSelectedCurrency.amountAsCurrency
            secondaryAccountValue += it.parityValueInSecondaryCurrency.amountAsCurrency
            assetCount++
        }
        return accountValueMapper.mapTo(
            primaryAccountValue = primaryAccountValue,
            secondaryAccountValue = secondaryAccountValue,
            assetCount = assetCount
        )
    }
}
