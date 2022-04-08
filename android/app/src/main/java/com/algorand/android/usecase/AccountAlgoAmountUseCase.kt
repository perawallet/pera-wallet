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
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.toAlgoDisplayValue
import java.math.BigDecimal
import java.math.BigDecimal.ZERO
import java.math.BigInteger
import javax.inject.Inject

class AccountAlgoAmountUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountAssetDataMapper: AccountAssetDataMapper
) {

    fun getAccountAlgoAmount(publicKey: String): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val accountAlgoAmount = accountDetailUseCase.getCachedAccountAlgoAmount(publicKey) ?: BigInteger.ZERO
        return createAccountAlgoAmount(accountAlgoAmount)
    }

    fun getAccountAlgoAmount(accountDetail: AccountDetail): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val accountAlgoAmount = accountDetail.accountInformation.amount
        return createAccountAlgoAmount(accountAlgoAmount)
    }

    private fun createAccountAlgoAmount(
        accountAlgoAmount: BigInteger
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        val algoPrice = algoPriceUseCase.getAlgoToSelectedCurrencyConversionRate() ?: ZERO
        val amountInSelectedCurrency = accountAlgoAmount.toAlgoDisplayValue().multiply(algoPrice) ?: ZERO
        val algoToCachedCurrencyRate = algoPriceUseCase.getAlgoToCachedCurrencyConversionRate() ?: ZERO
        val algoUsdValue = algoPriceUseCase.getAlgoToUsdConversionRate()
        val amountInCachedCurrency = accountAlgoAmount.toAlgoDisplayValue().multiply(algoToCachedCurrencyRate) ?: ZERO
        val formattedAlgoAmountInCachedCurrency = formatAlgoAmountToCachedCurrency(amountInCachedCurrency)
        return accountAssetDataMapper.mapToAlgoAssetData(
            accountAlgoAmount,
            amountInSelectedCurrency,
            formattedAlgoAmountInCachedCurrency,
            algoUsdValue
        )
    }

    private fun formatAlgoAmountToCachedCurrency(algoAmountInCachedCurrency: BigDecimal): String {
        val cachedCurrencySymbol = algoPriceUseCase.getCachedCurrencySymbolOrName()
        return algoAmountInCachedCurrency.formatAsCurrency(cachedCurrencySymbol)
    }
}
