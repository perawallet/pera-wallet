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

package com.algorand.android.modules.transaction.detail.ui.mapper

import com.algorand.android.modules.transaction.detail.domain.model.TransactionDetailPreview
import com.algorand.android.modules.transaction.detail.ui.model.TransactionDetailItem
import javax.inject.Inject

class TransactionDetailPreviewMapper @Inject constructor() {

    fun mapTo(
        isLoading: Boolean,
        transactionDetailItemList: List<TransactionDetailItem>,
        toolbarTitleResId: Int? = null
    ): TransactionDetailPreview {
        return TransactionDetailPreview(
            isLoading = isLoading,
            transactionDetailItemList = transactionDetailItemList,
            toolbarTitleResId = toolbarTitleResId
        )
    }
}
