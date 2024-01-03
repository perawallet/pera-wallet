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

package com.algorand.android.mapper

import com.algorand.android.models.AssetTransferPreview
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import java.math.BigDecimal
import javax.inject.Inject

class AssetTransferPreviewMapper @Inject constructor() {

    fun mapToAssetTransferPreview(
        transactionData: TransactionData.Send,
        exchangePrice: BigDecimal,
        currencySymbol: String,
        note: String?,
        isNoteEditable: Boolean,
        accountIconDrawablePreview: AccountIconDrawablePreview
    ): AssetTransferPreview {
        with(transactionData) {
            return AssetTransferPreview(
                amount = amount,
                assetInformation = assetInformation,
                targetUser = targetUser,
                exchangePrice = exchangePrice,
                currencySymbol = currencySymbol,
                fee = calculatedFee ?: projectedFee,
                note = note,
                isNoteEditable = isNoteEditable,
                accountIconDrawablePreview = accountIconDrawablePreview,
                senderAccountName = senderAccountName,
                senderAccountAddress = senderAccountAddress
            )
        }
    }
}
