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

package com.algorand.android.modules.accountdetail.removeaccount.ui.mapper

import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.accountdetail.removeaccount.ui.model.RemoveAccountConfirmationPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class RemoveAccountConfirmationPreviewMapper @Inject constructor() {

    fun mapToRemoveAccountConfirmationPreview(
        showGlobalErrorEvent: Event<PluralAnnotatedString>? = null,
        navBackEvent: Event<Boolean>? = null
    ): RemoveAccountConfirmationPreview {
        return RemoveAccountConfirmationPreview(
            showGlobalErrorEvent = showGlobalErrorEvent,
            navBackEvent = navBackEvent
        )
    }
}
