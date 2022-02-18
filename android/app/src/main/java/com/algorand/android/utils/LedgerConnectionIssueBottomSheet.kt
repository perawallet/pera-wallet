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

package com.algorand.android.utils

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString

class LedgerConnectionIssueBottomSheet : BaseSingleButtonBottomSheet() {

    override val title: AnnotatedString
        get() = AnnotatedString(R.string.having_ledger_nano_x)
    override val iconDrawableResId: Int
        get() = R.drawable.ic_error
    override val iconDrawableTintResId: Int
        get() = R.color.errorTintColor
    override val descriptionAnnotatedString: AnnotatedString?
        get() = AnnotatedString(R.string.make_sure_the_device_is)

    override fun onConfirmationButtonClick() {
        navBack()
    }
}
