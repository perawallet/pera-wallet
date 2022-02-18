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
import com.algorand.android.models.Account
import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.Result
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TrackTransactionRequest
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.analytics.logTransactionEvent
import com.google.firebase.analytics.FirebaseAnalytics
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AssetTransferPreviewUseCase @Inject constructor(
    private val assetTransferPreviewMapper: AssetTransferPreviewMapper,
    private val transactionsRepository: TransactionsRepository,
    private val algodInterceptor: AlgodInterceptor,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val algoPriceUseCase: AlgoPriceUseCase
) {

    fun getAssetTransferPreview(
        signedTransactionDetail: SignedTransactionDetail.Send
    ): AssetTransferPreview {
        val currencyValue = algoPriceUseCase.getCachedAlgoPrice()?.data
        val exchangePrice = currencyValue?.exchangePrice?.toBigDecimalOrNull() ?: BigDecimal.ZERO
        val currencySymbol = currencyValue?.symbol ?: algoPriceUseCase.getSelectedCurrencySymbol()
        return assetTransferPreviewMapper.mapToAssetTransferPreview(
            signedTransactionDetail = signedTransactionDetail,
            exchangePrice = exchangePrice,
            currencySymbol = currencySymbol
        )
    }

    suspend fun sendSignedTransaction(signedTransactionDetail: SignedTransactionDetail.Send) = flow {
        val signedTransactionData = signedTransactionDetail.signedTransactionData
        when (val result = transactionsRepository.sendSignedTransaction(signedTransactionData)) {
            is Result.Success -> {
                result.data.taxId?.run {
                    transactionsRepository.postTrackTransaction(TrackTransactionRequest(this@run))
                }
                logTransactionEvent(signedTransactionDetail, result.data.taxId)
                emit(Result.Success(result.data))
            }
            is Result.Error -> {
                emit(Result.Error(result.exception))
            }
        }
    }

    private fun logTransactionEvent(signedTransactionDetail: SignedTransactionDetail.Send, taxId: String?) {
        if (algodInterceptor.currentActiveNode?.networkSlug == MAINNET_NETWORK_SLUG) {
            with(signedTransactionDetail) {
                firebaseAnalytics.logTransactionEvent(
                    amount = amount,
                    assetId = assetInformation.assetId,
                    accountType = accountCacheData.account.type ?: Account.Type.STANDARD,
                    isMax = isMax,
                    transactionId = taxId
                )
            }
        }
    }
}
