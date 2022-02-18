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

package com.algorand.android.models.builder

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.WalletConnectTransactionSummary
import javax.inject.Inject

class BaseAssetTransferTransactionSummaryUiBuilder @Inject constructor() :
    WalletConnectTransactionSummaryUIBuilder<BaseAssetTransferTransaction> {

    override fun buildTransactionSummary(txn: BaseAssetTransferTransaction): WalletConnectTransactionSummary {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> buildAssetOptInTransactionSummary(txn)
            else -> buildGeneralTransactionSummary(txn)
        }
    }

    private fun buildGeneralTransactionSummary(txn: BaseAssetTransferTransaction): WalletConnectTransactionSummary {
        return with(txn) {
            WalletConnectTransactionSummary(
                accountName = account?.name,
                accountIcon = createAccountIcon(),
                accountBalance = assetInformation?.amount,
                assetShortName = assetParams?.shortName,
                assetDecimal = assetDecimal,
                transactionAmount = transactionAmount,
                showWarning = warningCount != null,
                formattedSelectedCurrencyValue = assetInformation?.formattedSelectedCurrencyValue
            )
        }
    }

    private fun buildAssetOptInTransactionSummary(
        txn: BaseAssetTransferTransaction.AssetOptInTransaction
    ): WalletConnectTransactionSummary {
        return with(txn) {
            val titleText = AnnotatedString(
                stringResId = R.string.possible_opt_in_request_with_asset_id,
                replacementList = listOf("asset_id" to assetId.toString())
            )
            WalletConnectTransactionSummary(
                accountName = account?.name,
                accountIcon = createAccountIcon(),
                summaryTitle = titleText,
                showWarning = warningCount != null,
                showMoreButtonText = R.string.show_all_details
            )
        }
    }
}
