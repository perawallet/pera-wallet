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
import com.algorand.android.models.BaseKeyRegTransaction
import com.algorand.android.models.WalletConnectTransactionSummary
import javax.inject.Inject

class BaseKeyRegTransactionSummaryUiBuilder @Inject constructor() :
    WalletConnectTransactionSummaryUIBuilder<BaseKeyRegTransaction> {

    override fun buildTransactionSummary(txn: BaseKeyRegTransaction): WalletConnectTransactionSummary {
        return with(txn) {
            WalletConnectTransactionSummary(
                accountName = fromAccount?.name,
                accountIconDrawablePreview = getFromAccountIconResource(),
                showWarning = warningCount != null,
                summaryTitle = AnnotatedString(R.string.key_reg)
            )
        }
    }
}
