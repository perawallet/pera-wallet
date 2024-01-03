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

package com.algorand.android.modules.dapp.transak.ui.intro.usecase

import com.algorand.android.modules.dapp.transak.getTransakSupportedAssetIdList
import com.algorand.android.modules.dapp.transak.ui.intro.mapper.TransakIntroPreviewMapper
import com.algorand.android.modules.dapp.transak.ui.intro.model.TransakIntroPreview
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.IsOnMainnetUseCase
import com.algorand.android.utils.isStagingApp
import javax.inject.Inject

class TransakIntroPreviewUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val transakIntroPreviewMapper: TransakIntroPreviewMapper,
    private val isOnMainnetUseCase: IsOnMainnetUseCase
) {

    fun getInitialStatePreview() = transakIntroPreviewMapper.mapToInitialPreview()

    fun getNavigateToNextScreenUpdatedPreview(
        previousState: TransakIntroPreview,
        accountAddress: String?
    ): TransakIntroPreview {
        val assetsNeedingOptInList = if (accountAddress == null) {
            null
        } else {
            val accountAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, includeAlgo = true)
            getTransakSupportedAssetIdList(isOnMainnetUseCase.invoke())
                .filter { supportedCurrencyAssetId ->
                    accountAssetData.none { it.id == supportedCurrencyAssetId }
                }
        }
        return transakIntroPreviewMapper.mapToAccountSelectedPreview(
            previousState = previousState,
            accountAddress = accountAddress,
            assetsNeedingOptInList = assetsNeedingOptInList,
            isTransakBrowserAllowed = isTransakBrowserAllowed(),
            isMainNet = isOnMainnetUseCase.invoke()
        )
    }

    fun getOnAssetOptedInPreview(
        previousState: TransakIntroPreview,
        accountAddress: String
    ): TransakIntroPreview {
        return transakIntroPreviewMapper.mapToAssetOptedInPreview(
            previousState = previousState,
            accountAddress = accountAddress,
            isMainNet = isOnMainnetUseCase.invoke()
        )
    }

    private fun isTransakBrowserAllowed(): Boolean {
        return isStagingApp() || isOnMainnetUseCase.invoke()
    }
}
