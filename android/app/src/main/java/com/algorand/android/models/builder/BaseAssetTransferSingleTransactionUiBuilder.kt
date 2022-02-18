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
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.WalletConnectTransactionAmount
import com.algorand.android.models.WalletConnectTransactionShortDetail
import javax.inject.Inject

class BaseAssetTransferSingleTransactionUiBuilder @Inject constructor() :
    WalletConnectSingleTransactionUiBuilder<BaseAssetTransferTransaction> {

    override fun buildToolbarTitleRes(txn: BaseAssetTransferTransaction): Int {
        return when (txn) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> R.string.possible_opt_in_request
            else -> R.string.transaction_request
        }
    }

    override fun buildTransactionShortDetail(txn: BaseAssetTransferTransaction): WalletConnectTransactionShortDetail {
        return with(txn) {
            WalletConnectTransactionShortDetail(
                accountIcon = createAccountIcon(),
                accountName = account?.name,
                accountBalance = assetBalance,
                warningCount = warningCount,
                assetShortName = assetParams?.shortName,
                decimal = assetDecimal,
                fee = fee
            )
        }
    }

    override fun buildTransactionAmount(txn: BaseAssetTransferTransaction): WalletConnectTransactionAmount {
        return with(txn) {
            WalletConnectTransactionAmount(
                assetName = assetParams?.fullName,
                assetId = assetId,
                transactionAmount = transactionAmount,
                assetDecimal = assetDecimal,
                assetShortName = assetParams?.shortName,
                formattedSelectedCurrencyValue = assetInformation?.formattedSelectedCurrencyValue
            )
        }
    }
}
