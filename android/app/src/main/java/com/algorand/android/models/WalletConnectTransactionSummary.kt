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

package com.algorand.android.models

import android.os.Parcelable
import androidx.annotation.StringRes
import com.algorand.android.R
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class WalletConnectTransactionSummary(
    val accountName: String? = null,
    val accountIcon: AccountIcon? = null,
    val accountBalance: BigInteger? = null,
    val assetDecimal: Int? = null,
    val assetShortName: String? = null,
    val transactionAmount: BigInteger? = null,
    val summaryTitle: AnnotatedString? = null,
    val showWarning: Boolean = false,
    @StringRes val showMoreButtonText: Int = R.string.show_transaction_details,
    val formattedSelectedCurrencyValue: String? = null
) : Parcelable
