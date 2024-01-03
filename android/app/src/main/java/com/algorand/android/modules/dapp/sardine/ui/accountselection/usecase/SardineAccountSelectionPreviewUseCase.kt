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

package com.algorand.android.modules.dapp.sardine.ui.accountselection.usecase

import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.modules.dapp.sardine.ui.accountselection.mapper.SardineAccountSelectionPreviewMapper
import com.algorand.android.modules.dapp.sardine.ui.accountselection.model.SardineAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import com.algorand.android.usecase.IsOnMainnetUseCase
import javax.inject.Inject

class SardineAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val sardineAccountSelectionPreviewMapper: SardineAccountSelectionPreviewMapper,
    private val isOnMainnetUseCase: IsOnMainnetUseCase
) {

    fun getInitialPreview(): SardineAccountSelectionPreview {
        return sardineAccountSelectionPreviewMapper.mapToInitialPreview()
    }

    suspend fun getSardineAccountSelectionList(): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase.createAccountSelectionListAccountItemsWhichCanSignTransaction(
            showHoldings = true,
            showFailedAccounts = false
        )
    }

    fun getOnAccountSelectedPreview(
        previousState: SardineAccountSelectionPreview,
        accountAddress: String
    ): SardineAccountSelectionPreview {
        return sardineAccountSelectionPreviewMapper.mapToAccountSelectedPreview(
            previousState = previousState,
            accountAddress = accountAddress,
            isMainnet = isOnMainnetUseCase.invoke()
        )
    }
}
