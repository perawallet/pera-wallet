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

package com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.ScreenState
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.mapper.RekeyToAccountSelectionPreviewMapper
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.model.RekeyToAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import javax.inject.Inject

class RekeyToAccountSelectionPreviewUseCase @Inject constructor(
    private val rekeyToAccountSelectionPreviewMapper: RekeyToAccountSelectionPreviewMapper,
    private val accountSelectionListUseCase: AccountSelectionListUseCase
) {

    suspend fun getInitialRekeyToAccountSelectionPreview(
        accountAddress: String
    ): RekeyToAccountSelectionPreview {
        val accountSelectionItemList = accountSelectionListUseCase
            .createAccountSelectionListAccountItemsWhichCanSignTransaction(
                showHoldings = true,
                showFailedAccounts = false,
                excludedAccountTypes = listOf(Account.Type.REKEYED, Account.Type.LEDGER, Account.Type.REKEYED_AUTH)
            ).filter { it.publicKey != accountAddress }

        val screenState = if (accountSelectionItemList.isEmpty()) {
            ScreenState.CustomState(title = R.string.no_account_found)
        } else {
            null
        }

        return rekeyToAccountSelectionPreviewMapper.mapToRekeyToAccountSelectionPreview(
            accountSelectionListItem = accountSelectionItemList,
            screenState = screenState
        )
    }
}
