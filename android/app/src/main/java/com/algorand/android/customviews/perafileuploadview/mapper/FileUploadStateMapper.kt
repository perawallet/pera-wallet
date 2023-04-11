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

package com.algorand.android.customviews.perafileuploadview.mapper

import com.algorand.android.customviews.perafileuploadview.model.FileUploadState
import com.algorand.android.models.AnnotatedString
import javax.inject.Inject

class FileUploadStateMapper @Inject constructor() {

    fun mapToInitial(): FileUploadState.Initial {
        return FileUploadState.Initial
    }

    fun mapToUploading(fileName: String?): FileUploadState.Uploading {
        return FileUploadState.Uploading(fileName)
    }

    fun mapToSuccessful(fileName: String?): FileUploadState.Successful {
        return FileUploadState.Successful(fileName)
    }

    fun mapToFailure(
        fileName: String?,
        errorStatusAnnotatedString: AnnotatedString
    ): FileUploadState.Failure {
        return FileUploadState.Failure(errorStatusAnnotatedString, fileName)
    }
}
