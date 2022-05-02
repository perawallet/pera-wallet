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

package com.algorand.android.mapper

import com.algorand.android.models.BaseAccountAdditionResultInfoPreview
import javax.inject.Inject

class BaseAccountAdditionResultInfoPreviewMapper @Inject constructor() {

    fun mapToWatchAccountAdditionResultInfoPreview(
        titleTextRes: Int,
        descriptionTextRes: Int,
        firstButtonTextRes: Int
    ): BaseAccountAdditionResultInfoPreview.WatchAccountAAdditionResultInfoPreview {
        return BaseAccountAdditionResultInfoPreview.WatchAccountAAdditionResultInfoPreview(
            titleTextRes = titleTextRes,
            descriptionTextRes = descriptionTextRes,
            firstButtonTextRes = firstButtonTextRes
        )
    }

    fun mapToRecoverAccountResultInfoPreview(
        titleTextRes: Int,
        descriptionTextRes: Int,
        firstButtonTextRes: Int,
        secondButtonTextRes: Int
    ): BaseAccountAdditionResultInfoPreview.RecoverAccountResultInfoPreview {
        return BaseAccountAdditionResultInfoPreview.RecoverAccountResultInfoPreview(
            titleTextRes = titleTextRes,
            descriptionTextRes = descriptionTextRes,
            firstButtonTextRes = firstButtonTextRes,
            secondButtonTextRes = secondButtonTextRes
        )
    }

    fun mapToCreateAccountResultInfoPreview(
        titleTextRes: Int,
        descriptionTextRes: Int,
        firstButtonTextRes: Int,
        secondButtonTextRes: Int
    ): BaseAccountAdditionResultInfoPreview.CreateAccountResultInfoPreview {
        return BaseAccountAdditionResultInfoPreview.CreateAccountResultInfoPreview(
            titleTextRes = titleTextRes,
            descriptionTextRes = descriptionTextRes,
            firstButtonTextRes = firstButtonTextRes,
            secondButtonTextRes = secondButtonTextRes
        )
    }

    fun mapToLedgerAccountAdditionResultInfoPreview(
        titleTextRes: Int,
        descriptionTextRes: Int,
        firstButtonTextRes: Int,
        secondButtonTextRes: Int
    ): BaseAccountAdditionResultInfoPreview.LedgerAccountAdditionResultInfoPreview {
        return BaseAccountAdditionResultInfoPreview.LedgerAccountAdditionResultInfoPreview(
            titleTextRes = titleTextRes,
            descriptionTextRes = descriptionTextRes,
            firstButtonTextRes = firstButtonTextRes,
            secondButtonTextRes = secondButtonTextRes
        )
    }
}
