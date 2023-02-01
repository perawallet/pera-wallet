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

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AssetTransferAmountAssetPreview
import com.algorand.android.models.AssetTransferAmountPreview
import com.algorand.android.utils.Event
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class AssetTransferAmountPreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToSuccessPreview(
        assetTransferAmountAssetPreview: AssetTransferAmountAssetPreview,
        enteredAmountSelectedCurrencyValue: String?,
        decimalSeparator: String,
        selectedAmount: BigDecimal?,
        senderAddress: String,
        accountName: String,
        accountIconResource: AccountIconResource,
        onMaxAmountEvent: Event<Unit>? = null,
        amountIsValidEvent: Event<BigInteger?>? = null,
        amountIsMoreThanBalanceEvent: Event<Unit>? = null,
        insufficientBalanceToPayFeeEvent: Event<Unit>? = null,
        minimumBalanceIsViolatedResultEvent: Event<String?>? = null,
        assetNotFoundErrorEvent: Event<Unit>? = null
    ): AssetTransferAmountPreview {
        return AssetTransferAmountPreview(
            assetPreview = assetTransferAmountAssetPreview,
            enteredAmountSelectedCurrencyValue = enteredAmountSelectedCurrencyValue,
            decimalSeparator = decimalSeparator,
            selectedAmount = selectedAmount,
            senderAddress = senderAddress,
            onPopulateAmountWithMaxEvent = onMaxAmountEvent,
            amountIsValidEvent = amountIsValidEvent,
            amountIsMoreThanBalanceEvent = amountIsMoreThanBalanceEvent,
            insufficientBalanceToPayFeeEvent = insufficientBalanceToPayFeeEvent,
            minimumBalanceIsViolatedResultEvent = minimumBalanceIsViolatedResultEvent,
            assetNotFoundErrorEvent = assetNotFoundErrorEvent,
            accountName = accountName,
            accountIconResource = accountIconResource
        )
    }

    fun mapToAssetNotFoundStatePreview() = AssetTransferAmountPreview(assetNotFoundErrorEvent = Event(Unit))
}
