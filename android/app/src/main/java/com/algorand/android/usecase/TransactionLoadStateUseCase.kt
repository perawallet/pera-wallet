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

package com.algorand.android.usecase

import androidx.paging.CombinedLoadStates
import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.TransactionLoadStatePreviewMapper
import com.algorand.android.models.ui.TransactionLoadStatePreview
import javax.inject.Inject

class TransactionLoadStateUseCase @Inject constructor(
    private val transactionLoadStatePreviewMapper: TransactionLoadStatePreviewMapper
) : BaseUseCase() {

    fun createTransactionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): TransactionLoadStatePreview {
        return transactionLoadStatePreviewMapper.mapToTransactionLoadStatePreview(
            combinedLoadStates,
            itemCount,
            isLastStateError
        )
    }
}
