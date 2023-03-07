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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.mapper

import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.model.RekeyToStandardAccountConfirmationPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class RekeyToStandardAccountConfirmationPreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToRekeyToStandardAccountConfirmationPreview(
        oldAccountTypeIconResource: AccountIconResource,
        oldAccountTitleTextResId: Int,
        oldAccountDisplayName: String,
        newAccountTypeIconResource: AccountIconResource,
        newAccountTitleTextResId: Int,
        newAccountDisplayName: String,
        isLoading: Boolean,
        onDisplayCalculatedTransactionFeeEvent: Event<String>? = null,
        popRekeyToStandardAccountNavigationUpEvent: Event<Unit>? = null,
        showGlobalError: Event<String>? = null
    ): RekeyToStandardAccountConfirmationPreview {
        return RekeyToStandardAccountConfirmationPreview(
            oldAccountTypeIconResource = oldAccountTypeIconResource,
            oldAccountTitleTextResId = oldAccountTitleTextResId,
            oldAccountDisplayName = oldAccountDisplayName,
            newAccountTypeIconResource = newAccountTypeIconResource,
            newAccountTitleTextResId = newAccountTitleTextResId,
            newAccountDisplayName = newAccountDisplayName,
            onDisplayCalculatedTransactionFeeEvent = onDisplayCalculatedTransactionFeeEvent,
            isLoading = isLoading,
            navToRekeyToStandardAccountVerifyFragmentEvent = popRekeyToStandardAccountNavigationUpEvent,
            showGlobalErrorEvent = showGlobalError
        )
    }
}
