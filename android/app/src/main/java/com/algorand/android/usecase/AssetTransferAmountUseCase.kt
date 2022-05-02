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
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.Result
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinimumBalance
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.formatAmountAsBigInteger
import com.algorand.android.utils.validator.AmountTransactionValidator
import java.math.BigDecimal
import java.math.BigInteger
import java.math.BigInteger.ZERO
import javax.inject.Inject

// TODO: 29.09.2021 Some validations are updated in master, be careful while merging here
class AssetTransferAmountUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val assetTransferAmountPreviewMapper: AssetTransferAmountPreviewMapper,
    private val amountTransactionValidator: AmountTransactionValidator,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase
) {

    fun getAssetTransferAmountPreview(
        fromAccountPublicKey: String,
        assetId: Long,
        amount: BigDecimal = BigDecimal.ZERO
    ): AssetTransferAmountPreview? {
        val accountAssetData = getAccountAssetData(assetId, fromAccountPublicKey) ?: return null
        val isAlgo = assetId == ALGORAND_ID
        with(algoPriceUseCase) {
            val enteredAmountSelectedCurrencyValue = formatEnteredAmount(
                amount,
                accountAssetData.usdValue,
                if (isAlgo) getUsdToCachedCurrencyConversionRate() else getUsdToSelectedCurrencyConversionRate(),
                if (isAlgo) getCachedCurrencySymbolOrName() else getSelectedCurrencySymbolOrCurrencyName()
            )
            // TODO Refactor two lines below
            val collectiblePrismUrl = (accountAssetData as? OwnedCollectibleImageData)?.prismUrl
            val isCollectibleOwnedByUser = (accountAssetData as? BaseOwnedCollectibleData)?.amount ?: ZERO > ZERO
            return assetTransferAmountPreviewMapper.mapTo(
                accountAssetData = accountAssetData,
                enteredAmountSelectedCurrencyValue = enteredAmountSelectedCurrencyValue,
                collectiblePrismUrl,
                isCollectibleOwnedByUser
            )
        }
    }

    fun validateAssetAmount(amount: BigDecimal, fromAccountPublicKey: String, assetId: Long): Result<BigInteger> {
        return amountTransactionValidator.validateAssetAmount(amount, fromAccountPublicKey, assetId)
    }

    fun getCalculatedMinimumBalance(amount: BigDecimal, assetId: Long, publicKey: String): Result<BigInteger> {
        // Find better exception message
        val accountCacheData = accountCacheManager.getCacheData(publicKey) ?: return Result.Error(Exception())
        val selectedAsset = getAccountAssetData(assetId, publicKey) ?: return Result.Error(Exception())
        val amountInBigInteger = amount.formatAmountAsBigInteger(selectedAsset.decimals)
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

    fun getMaximumAmountOfAsset(assetId: Long, publicKey: String): String? {
        return getAccountAssetData(assetId, publicKey)?.formattedAmount
    }

    private fun getAccountAssetData(assetId: Long, publicKey: String): BaseAccountAssetData.BaseOwnedAssetData? {
        return getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(assetId, publicKey)
    }

    private fun formatEnteredAmount(
        amount: BigDecimal,
        usdValue: BigDecimal?,
        usdToDisplayedCurrencyConversionRate: BigDecimal?,
        cachedCurrencySymbol: String
    ): String? {
        return amount.multiply(usdValue ?: return null)
            .multiply(usdToDisplayedCurrencyConversionRate ?: return null)
            .formatAsCurrency(cachedCurrencySymbol)
    }
}
