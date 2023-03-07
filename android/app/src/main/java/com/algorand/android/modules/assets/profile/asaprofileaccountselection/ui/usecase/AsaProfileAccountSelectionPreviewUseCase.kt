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

package com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.usecase

import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.mapper.AsaProfileAccountSelectionPreviewMapper
import com.algorand.android.modules.assets.profile.asaprofileaccountselection.ui.model.AsaProfileAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

class AsaProfileAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val asaProfileAccountSelectionPreviewMapper: AsaProfileAccountSelectionPreviewMapper
) {

    fun getInitialAccountSelectionPreview(): AsaProfileAccountSelectionPreview {
        return asaProfileAccountSelectionPreviewMapper.mapToAsaProfileAccountSelectionPreview(
            accountListItems = emptyList(),
            isLoading = true
        )
    }

    suspend fun getAccountSelectionPreviewFlow(): Flow<AsaProfileAccountSelectionPreview> = flow {
        val accountSelectionList = accountSelectionListUseCase
            .createAccountSelectionListAccountItemsWhichCanSignTransaction(
                showFailedAccounts = true,
                showHoldings = false
            )
        emit(
            asaProfileAccountSelectionPreviewMapper.mapToAsaProfileAccountSelectionPreview(
                accountListItems = accountSelectionList,
                isLoading = false
            )
        )
    }
}
