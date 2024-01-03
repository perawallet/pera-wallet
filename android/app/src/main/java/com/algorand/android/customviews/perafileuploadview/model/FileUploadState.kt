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

package com.algorand.android.customviews.perafileuploadview.model

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString

sealed class FileUploadState {
    abstract val uploadStatusIconResId: Int?
    abstract val uploadStatusIconTintResId: Int?
    abstract val uploadActionButtonTextResId: Int?

    object Initial : FileUploadState() {
        const val uploadStatusTextResId: Int = R.string.select_your_backup_file
        override val uploadStatusIconResId: Int = R.drawable.ic_share
        override val uploadStatusIconTintResId: Int = R.color.text_main
        override val uploadActionButtonTextResId: Int? = null
    }

    data class Uploading(val fileName: String?) : FileUploadState() {
        val uploadStatusTextResId: Int = R.string.uploading_three_dots
        override val uploadStatusIconResId: Int? = null
        override val uploadStatusIconTintResId: Int = R.color.text_main
        override val uploadActionButtonTextResId: Int = R.string.cancel
    }

    data class Successful(val fileName: String?) : FileUploadState() {
        val uploadStatusTextResId: Int = R.string.upload_successful
        override val uploadStatusIconResId: Int = R.drawable.ic_check
        override val uploadStatusIconTintResId: Int = R.color.success
        override val uploadActionButtonTextResId: Int = R.string.replace_file
    }

    data class Failure(
        val errorStatusAnnotatedString: AnnotatedString,
        val fileName: String?
    ) : FileUploadState() {
        override val uploadActionButtonTextResId: Int = R.string.select_file
        override val uploadStatusIconResId: Int = R.drawable.ic_close
        override val uploadStatusIconTintResId: Int = R.color.negative
    }
}
