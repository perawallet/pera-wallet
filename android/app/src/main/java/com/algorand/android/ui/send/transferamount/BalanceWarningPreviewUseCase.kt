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

package com.algorand.android.ui.send.transferamount

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.MIN_BALANCE_TO_KEEP_PER_OPTED_IN_APPS
import com.algorand.android.utils.toAlgoDisplayValue
import javax.inject.Inject

class BalanceWarningPreviewUseCase @Inject constructor(
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val balanceWarningPreviewMapper: BalanceWarningPreviewMapper
) {
    fun getInitialPreview(accountAddress: String): BalanceWarningPreview {
        return balanceWarningPreviewMapper.mapTo(
            formattedAlgoAmount = getFormattedAlgoAmount(accountAddress),
            formattedAlgoPrimaryCurrencyValue = getFormattedAlgoPrimaryCurrencyValue(accountAddress),
            formattedMinBalanceToKeepPerOptedInAsset = getFormattedMinBalanceToKeepPerOptedInAsset()
        )
    }

    private fun getFormattedAlgoAmount(accountAddress: String): String? {
        return getAlgoData(accountAddress)?.formattedAmount
    }

    private fun getFormattedAlgoPrimaryCurrencyValue(accountAddress: String): String? {
        return getAlgoData(accountAddress)?.getSelectedCurrencyParityValue()?.getFormattedCompactValue()
    }

    private fun getFormattedMinBalanceToKeepPerOptedInAsset(): String {
        return MIN_BALANCE_TO_KEEP_PER_OPTED_IN_APPS
            .toBigInteger()
            .toAlgoDisplayValue()
            .stripTrailingZeros()
            .toPlainString()
    }

    private fun getAlgoData(accountAddress: String): BaseAccountAssetData.BaseOwnedAssetData? {
        return getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(AssetInformation.ALGO_ID, accountAddress)
    }
}
