/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.models

import android.content.Context
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.getXmlStyledString
import java.math.BigInteger

sealed class TransactionManagerResult {
    data class Success(val signedTransactionDetail: SignedTransactionDetail) : TransactionManagerResult()

    sealed class Error(@StringRes val titleResId: Int) : TransactionManagerResult() {
        fun getMessage(context: Context): Pair<String, CharSequence> {
            val title = context.getString(titleResId)
            return when (this) {
                is Defined -> Pair(title, context.getXmlStyledString(description))
                is MinBalanceError -> {
                    val annotatedString = AnnotatedString(
                        stringResId = R.string.you_need_at_least,
                        replacementList = listOf("min_balance" to neededBalance.formatAsAlgoString())
                    )
                    Pair(title, context.getXmlStyledString(annotatedString))
                }
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

        data class MinBalanceError(val neededBalance: BigInteger) : Error(titleResId = R.string.min_transaction_error)
    }

    object Loading : TransactionManagerResult()
    object LedgerWaitingForApproval : TransactionManagerResult()
}
