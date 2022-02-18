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
 *
 */

package com.algorand.android.usecase

import com.algorand.android.mapper.AssetTransferAmountPreviewMapper
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetTransferAmountPreview
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.Result
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinimumBalance
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.toFullAmountInBigInteger
import com.algorand.android.utils.validator.AmountTransactionValidator
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

// TODO: 29.09.2021 Some validations are updated in master, be careful while merging here
class AssetTransferAmountUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val assetTransferAmountPreviewMapper: AssetTransferAmountPreviewMapper,
    private val amountTransactionValidator: AmountTransactionValidator,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase
) {

    fun getAssetTransferAmountPreview(
        fromAccountPublicKey: String,
        assetId: Long,
        amount: BigDecimal = BigDecimal.ZERO
    ): AssetTransferAmountPreview? {

        val accountAssetData = getAccountAssetData(assetId, fromAccountPublicKey) ?: return null

        val assetInformation = accountCacheManager.getAssetInformation(fromAccountPublicKey, assetId)

        val formattedCurrencyValue = if (accountAssetData.usdValue != null) {
            val currencySymbol = algoPriceUseCase.getSelectedCurrencySymbol()
            amount.multiply(accountAssetData.usdValue)?.formatAsCurrency(currencySymbol)
        } else {
            null
        }

        return assetTransferAmountPreviewMapper.mapTo(
            assetInformation = assetInformation,
            accountAssetData = accountAssetData,
            formattedCurrencyValue = formattedCurrencyValue
        )
    }

    fun validateAssetAmount(amount: BigDecimal, fromAccountPublicKey: String, assetId: Long): Result<BigInteger> {
        val accountAssetDetail = getAccountAssetData(assetId, fromAccountPublicKey) ?: return Result.Error(Exception())
        val amountInBigInteger = amount.toFullAmountInBigInteger(accountAssetDetail.decimals)
        return amountTransactionValidator.validateAssetAmount(amountInBigInteger, fromAccountPublicKey, assetId)
    }

    fun getCalculatedMinimumBalance(amount: BigDecimal, assetId: Long, publicKey: String): Result<BigInteger> {
        // Find better exception message
        val accountCacheData = accountCacheManager.getCacheData(publicKey)
            ?: return Result.Error(Exception())
        val selectedAsset = accountCacheManager.getAssetInformation(publicKey, assetId)
            ?: return Result.Error(Exception())
        val amountInBigInteger = amount.toFullAmountInBigInteger(selectedAsset.decimals)
        return calculateMinimumBalance(amountInBigInteger, accountCacheData, selectedAsset)
    }

    fun getAssetInformation(publicKey: String, assetId: Long): AssetInformation? {
        return accountCacheManager.getAssetInformation(publicKey, assetId)
    }

    fun getAccountInformation(publicKey: String): AccountCacheData? {
        return accountCacheManager.getCacheData(publicKey)
    }

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }

    private fun getAccountAssetData(assetId: Long, publicKey: String): BaseAccountAssetData.OwnedAssetData? {
        return if (assetId == ALGORAND_ID) {
            accountAlgoAmountUseCase.getAccountAlgoAmount(publicKey)
        } else {
            val accountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)
            val assetQueryItem = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data ?: return null
            val assetHolding = accountDetail?.data?.accountInformation?.assetHoldingList?.firstOrNull {
                it.assetId == assetId
            } ?: return null
            accountAssetAmountUseCase.getAssetAmount(assetHolding, assetQueryItem)
        }
    }
}
