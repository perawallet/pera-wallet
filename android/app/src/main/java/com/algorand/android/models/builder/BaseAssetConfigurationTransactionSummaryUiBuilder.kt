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
import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetCreationTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetDeletionTransaction
import com.algorand.android.models.BaseAssetConfigurationTransaction.BaseAssetReconfigurationTransaction
import com.algorand.android.models.WalletConnectTransactionSummary
import javax.inject.Inject

class BaseAssetConfigurationTransactionSummaryUiBuilder @Inject constructor() :
    WalletConnectTransactionSummaryUIBuilder<BaseAssetConfigurationTransaction> {

    override fun buildTransactionSummary(txn: BaseAssetConfigurationTransaction): WalletConnectTransactionSummary {
        return when (txn) {
            is BaseAssetCreationTransaction -> buildAssetCreationSummary(txn)
            is BaseAssetReconfigurationTransaction -> buildAssetReconfigurationSummary(txn)
            is BaseAssetDeletionTransaction -> buildAssetDeletionSummary(txn)
        }
    }

    private fun buildAssetCreationSummary(txn: BaseAssetCreationTransaction): WalletConnectTransactionSummary {
        return with(txn) {
            val titleText = AnnotatedString(
                stringResId = R.string.asset_creation_request_with_asset_name,
                replacementList = listOf("asset_name" to assetName.orEmpty())
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

    private fun buildAssetReconfigurationSummary(
        txn: BaseAssetReconfigurationTransaction
    ): WalletConnectTransactionSummary {
        return with(txn) {
            val titleText = AnnotatedString(
                stringResId = R.string.asset_reconfiguration_request_with_asset_name,
                replacementList = listOf("asset_name" to assetName.orEmpty())
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

    private fun buildAssetDeletionSummary(txn: BaseAssetConfigurationTransaction): WalletConnectTransactionSummary {
        return with(txn) {
            val titleText = AnnotatedString(
                stringResId = R.string.asset_deletion_request_with_asset_name,
                replacementList = listOf("asset_name" to assetName.orEmpty())
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
