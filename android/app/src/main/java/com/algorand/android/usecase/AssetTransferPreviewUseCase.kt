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

import com.algorand.android.mapper.AssetTransferPreviewMapper
import com.algorand.android.models.AssetStatus
import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow

class AssetTransferPreviewUseCase @Inject constructor(
    private val assetTransferPreviewMapper: AssetTransferPreviewMapper,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun getAssetTransferPreview(
        signedTransactionDetail: SignedTransactionDetail.Send
    ): AssetTransferPreview {
        val exchangePrice = algoPriceUseCase.getAlgoToSelectedCurrencyConversionRate() ?: BigDecimal.ZERO
        return assetTransferPreviewMapper.mapToAssetTransferPreview(
            signedTransactionDetail = signedTransactionDetail,
            exchangePrice = exchangePrice,
            currencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrCurrencyName()
        )
    }

    suspend fun sendSignedTransaction(
        signedTransactionDetail: SignedTransactionDetail.Send
    ): Flow<DataResource<String>> {
        addAssetSendingToAccountCache(
            signedTransactionDetail.accountCacheData.account.address,
            signedTransactionDetail.assetInformation.assetId
        )
        return sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail)
    }

    private suspend fun addAssetSendingToAccountCache(publicKey: String, assetId: Long) {
        val cachedAccountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)?.data ?: return
        cachedAccountDetail.accountInformation.setAssetHoldingStatus(assetId, AssetStatus.PENDING_FOR_SENDING)
        accountDetailUseCase.cacheAccountDetail(CacheResult.Success.create(cachedAccountDetail))
    }
}
