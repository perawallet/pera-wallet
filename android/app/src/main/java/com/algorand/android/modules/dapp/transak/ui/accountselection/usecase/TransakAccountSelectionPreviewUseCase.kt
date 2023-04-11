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

package com.algorand.android.modules.dapp.transak.ui.accountselection.usecase

import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.modules.dapp.transak.getTransakSupportedAssetIdList
import com.algorand.android.modules.dapp.transak.ui.accountselection.mapper.TransakAccountSelectionPreviewMapper
import com.algorand.android.modules.dapp.transak.ui.accountselection.model.TransakAccountSelectionPreview
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.AccountSelectionListUseCase
import com.algorand.android.usecase.IsOnMainnetUseCase
import javax.inject.Inject

class TransakAccountSelectionPreviewUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val transakAccountSelectionPreviewMapper: TransakAccountSelectionPreviewMapper,
    private val isOnMainnetUseCase: IsOnMainnetUseCase
) {

    fun getInitialPreview(): TransakAccountSelectionPreview {
        return transakAccountSelectionPreviewMapper.mapToInitialPreview()
    }

    suspend fun getTransakAccountSelectionList(): List<BaseAccountSelectionListItem> {
        return accountSelectionListUseCase.createAccountSelectionListAccountItemsWhichCanSignTransaction(
            showHoldings = true,
            showFailedAccounts = false
        )
    }

    fun getOnAccountSelectedPreview(
        previousState: TransakAccountSelectionPreview,
        accountAddress: String
    ): TransakAccountSelectionPreview {
        val accountAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, includeAlgo = true)
        val assetsNeedingOptInList = getTransakSupportedAssetIdList(isOnMainnetUseCase.invoke())
            .filter { supportedCurrencyAssetId ->
                accountAssetData.none { it.id == supportedCurrencyAssetId }
            }
        return transakAccountSelectionPreviewMapper.mapToAccountSelectedPreview(
            previousState = previousState,
            accountAddress = accountAddress,
            assetsNeedingOptInList = assetsNeedingOptInList,
            isMainnet = isOnMainnetUseCase.invoke()
        )
    }

    fun getOnAssetOptedInPreview(
        previousState: TransakAccountSelectionPreview,
        accountAddress: String
    ): TransakAccountSelectionPreview {
        return transakAccountSelectionPreviewMapper.mapToAssetOptedInPreview(
            previousState = previousState,
            accountAddress = accountAddress,
            isMainnet = isOnMainnetUseCase.invoke()
        )
    }
}
