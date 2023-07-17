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

import com.algorand.android.mapper.AccountAssetDataMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.parity.domain.usecase.PrimaryCurrencyParityCalculationUseCase
import com.algorand.android.modules.parity.domain.usecase.SecondaryCurrencyParityCalculationUseCase
import java.math.BigInteger
import javax.inject.Inject

class AccountAlgoAmountUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val parityUseCase: ParityUseCase,
    private val accountAssetDataMapper: AccountAssetDataMapper,
    private val primaryCurrencyParityCalculationUseCase: PrimaryCurrencyParityCalculationUseCase,
    private val secondaryCurrencyParityCalculationUseCase: SecondaryCurrencyParityCalculationUseCase
) {

    fun getAccountAlgoAmount(publicKey: String): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val accountAlgoAmount = accountDetailUseCase.getCachedAccountAlgoAmount(publicKey) ?: BigInteger.ZERO
        return createAccountAlgoAmount(accountAlgoAmount)
    }

    fun getAccountAlgoAmount(accountDetail: AccountDetail): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val accountAlgoAmount = accountDetail.accountInformation.amount
        return createAccountAlgoAmount(accountAlgoAmount)
    }

    fun getAccountAlgoAmount(
        accountInformation: AccountInformation
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val accountAlgoAmount = accountInformation.amount
        return createAccountAlgoAmount(accountAlgoAmount)
    }

    private fun createAccountAlgoAmount(
        algoAmount: BigInteger
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val algoUsdValue = parityUseCase.getAlgoToUsdConversionRate()
        return accountAssetDataMapper.mapToAlgoAssetData(
            amount = algoAmount,
            parityValueInSelectedCurrency = primaryCurrencyParityCalculationUseCase.getAlgoParityValue(algoAmount),
            parityValueInSecondaryCurrency = secondaryCurrencyParityCalculationUseCase.getAlgoParityValue(algoAmount),
            usdValue = algoUsdValue
        )
    }
}
