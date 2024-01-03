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

package com.algorand.android.models

import android.content.Context
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.getXmlStyledString
import java.math.BigInteger

sealed class TransactionManagerResult {
    data class Success(val signedTransactionDetail: SignedTransactionDetail) : TransactionManagerResult()

    sealed class Error : TransactionManagerResult() {

        abstract val titleResId: Int

        sealed class GlobalWarningError : Error() {

            fun getMessage(context: Context): Pair<String, CharSequence> {
                val title = context.getString(titleResId)
                return when (this) {
                    is Defined -> Pair(title, context.getXmlStyledString(description))
                    is MinBalanceError -> {
                        Pair(title, context.getString(R.string.you_need_at_least, neededBalance.formatAsAlgoString()))
                    }
                    is Api -> Pair(title, errorMessage)
                }
            }

            data class Defined(
                val description: AnnotatedString,
                @StringRes override val titleResId: Int = R.string.error_default_title
            ) : GlobalWarningError()

            data class Api(
                val errorMessage: String,
                @StringRes override val titleResId: Int = R.string.error_default_title
            ) : GlobalWarningError()

            data class MinBalanceError(
                val neededBalance: BigInteger,
                @StringRes override val titleResId: Int = R.string.min_transaction_error
            ) : GlobalWarningError()
        }

        sealed class SnackbarError : Error() {

            abstract val descriptionResId: Int?
            abstract val buttonTextResId: Int?

            data class Retry(
                override val titleResId: Int,
                override val descriptionResId: Int?,
                override val buttonTextResId: Int = R.string.retry
            ) : SnackbarError()
        }
    }

    object LedgerOperationCanceled : TransactionManagerResult()

    object Loading : TransactionManagerResult()

    data class LedgerWaitingForApproval(val bluetoothName: String?) : TransactionManagerResult()

    object LedgerScanFailed : TransactionManagerResult()
}
