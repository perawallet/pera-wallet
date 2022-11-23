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

package com.algorand.android.decider

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Resource
import com.algorand.android.utils.Resource.Error.GlobalWarning
import com.algorand.android.utils.Resource.Error.Local
import java.io.File
import javax.inject.Inject

class CsvErrorResIdDecider @Inject constructor() {
    fun decideCsvErrorResId(dataResource: DataResource<File>): Resource.Error {
        // TODO: Use ErrorResource whenever merge this with [swap-feature]
        return when (dataResource) {
            is DataResource.Error.Api -> Local(dataResource.exception.message.orEmpty())
            is DataResource.Error.Local -> GlobalWarning(annotatedString = AnnotatedString(R.string.an_error_occured))
            else -> GlobalWarning(annotatedString = AnnotatedString(R.string.an_error_occured))
        }
    }
}
