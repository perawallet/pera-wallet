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

package com.algorand.android.modules.accountselection.ui.usecase

import com.algorand.android.modules.accountselection.ui.mapper.AddAssetAccountSelectionPreviewMapper
import com.algorand.android.modules.accountselection.ui.model.AddAssetAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import javax.inject.Inject

class AddAssetAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val addAssetAccountSelectionPreviewMapper: AddAssetAccountSelectionPreviewMapper
) {

    fun getInitialStatePreview() = addAssetAccountSelectionPreviewMapper.mapToAddAssetSelectionPreview(emptyList())

    suspend fun getAddAssetAccountSelectionPreview(): AddAssetAccountSelectionPreview {
        val accountSelectionListItems = accountSelectionListUseCase
            .createAccountSelectionListAccountItemsWhichCanSignTransaction(
                showHoldings = true,
                showFailedAccounts = true
            )
        return addAssetAccountSelectionPreviewMapper.mapToAddAssetSelectionPreview(accountSelectionListItems)
    }
}
