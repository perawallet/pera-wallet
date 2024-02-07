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
import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow

class AssetTransferPreviewUseCase @Inject constructor(
    private val assetTransferPreviewMapper: AssetTransferPreviewMapper,
    private val parityUseCase: ParityUseCase,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    fun getAssetTransferPreview(
        transactionData: TransactionData.Send
    ): AssetTransferPreview {
        val exchangePrice = parityUseCase.getAlgoToPrimaryCurrencyConversionRate()
        return assetTransferPreviewMapper.mapToAssetTransferPreview(
            transactionData = transactionData,
            exchangePrice = exchangePrice,
            currencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName(),
            note = transactionData.xnote ?: transactionData.note,
            isNoteEditable = transactionData.xnote == null,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(transactionData.senderAccountAddress)
        )
    }

    suspend fun sendSignedTransaction(
        signedTransactionDetail: SignedTransactionDetail.Send
    ): Flow<DataResource<String>> {
        return sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail)
    }
}
