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

package com.algorand.android.utils.exceptions

import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ExceptionErrorParser
import com.algorand.android.utils.Resource

data class GlobalException(
    @StringRes val titleRes: Int? = null,
    val descriptionString: AnnotatedString? = null,
    @StringRes val descriptionRes: Int
) : Exception(), ExceptionErrorParser {
    override fun getAsResourceError(): Resource.Error {
        val descriptionString = descriptionString ?: AnnotatedString(stringResId = descriptionRes)
        return Resource.Error.GlobalWarning(titleRes, descriptionString)
    }
}
