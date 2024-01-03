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

package com.algorand.android.modules.rekey.baserekeyconfirmation.ui.model

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.Event

interface BaseRekeyConfirmationFields {
    val isLoading: Boolean
    val titleTextResId: Int
    val descriptionAnnotatedString: AnnotatedString
    val subtitleTextResId: Int
    val rekeyedAccountDisplayName: AccountDisplayName
    val rekeyedAccountIconResource: AccountIconDrawablePreview
    val authAccountDisplayName: AccountDisplayName
    val authAccountIconResource: AccountIconDrawablePreview
    val currentlyRekeyedAccountDisplayName: AccountDisplayName?
    val currentlyRekeyedAccountIconDrawable: AccountIconDrawablePreview?
    val formattedTransactionFee: String?
    val navToRekeyResultInfoFragmentEvent: Event<Unit>?
    val showGlobalErrorEvent: Event<Pair<Int, String>>?
    val navToRekeyedAccountConfirmationBottomSheetEvent: Event<Unit>?
    val onSendTransactionEvent: Event<Unit>?

    val isTransactionFeeGroupIsVisible: Boolean
        get() = !formattedTransactionFee.isNullOrBlank()

    val isCurrentlyRekeyedAccountGroupVisible: Boolean
        get() = currentlyRekeyedAccountDisplayName != null || currentlyRekeyedAccountIconDrawable != null
}
