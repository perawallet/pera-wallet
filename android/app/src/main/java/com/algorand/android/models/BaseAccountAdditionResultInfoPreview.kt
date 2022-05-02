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

package com.algorand.android.models

sealed class BaseAccountAdditionResultInfoPreview {

    abstract val titleTextRes: Int
    abstract val descriptionTextRes: Int
    abstract val firstButtonTextRes: Int

    open val secondButtonTextRes: Int? = null

    data class WatchAccountAAdditionResultInfoPreview(
        override val titleTextRes: Int,
        override val descriptionTextRes: Int,
        override val firstButtonTextRes: Int
    ) : BaseAccountAdditionResultInfoPreview()

    data class RecoverAccountResultInfoPreview(
        override val titleTextRes: Int,
        override val descriptionTextRes: Int,
        override val firstButtonTextRes: Int,
        override val secondButtonTextRes: Int
    ) : BaseAccountAdditionResultInfoPreview()

    data class CreateAccountResultInfoPreview(
        override val titleTextRes: Int,
        override val descriptionTextRes: Int,
        override val firstButtonTextRes: Int,
        override val secondButtonTextRes: Int
    ) : BaseAccountAdditionResultInfoPreview()

    data class LedgerAccountAdditionResultInfoPreview(
        override val titleTextRes: Int,
        override val descriptionTextRes: Int,
        override val firstButtonTextRes: Int,
        override val secondButtonTextRes: Int
    ) : BaseAccountAdditionResultInfoPreview()
}
