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

package com.algorand.android.modules.transaction.signmanager

import android.content.Context
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.getXmlStyledString

sealed class ExternalTransactionSignResult {

    data class Success<T>(
        val signedTransaction: List<T>
    ) : ExternalTransactionSignResult()

    sealed class Error(@StringRes val titleResId: Int) : ExternalTransactionSignResult() {
        fun getMessage(context: Context): Pair<String, CharSequence> {
            val title = context.getString(titleResId)
            return when (this) {
                is Defined -> Pair(title, context.getXmlStyledString(description))
                is Api -> Pair(title, errorMessage)
            }
        }

        class Defined(
            val description: AnnotatedString,
            @StringRes titleResId: Int = R.string.error_default_title
        ) : Error(titleResId)

        class Api(
            val errorMessage: String,
            @StringRes titleResId: Int = R.string.error_default_title
        ) : Error(titleResId)
    }

    data class TransactionCancelled(
        val error: Error = Error.Defined(
            AnnotatedString(R.string.error_cancelled_message),
            R.string.error_cancelled_title
        )
    ) : ExternalTransactionSignResult()

    object Loading : ExternalTransactionSignResult()

    data class LedgerWaitingForApproval(
        val ledgerName: String?,
        val currentTransactionIndex: Int?,
        val totalTransactionCount: Int?,
        val isTransactionIndicatorVisible: Boolean
    ) : ExternalTransactionSignResult()

    object LedgerScanFailed : ExternalTransactionSignResult()
    object NotInitialized : ExternalTransactionSignResult()
}
