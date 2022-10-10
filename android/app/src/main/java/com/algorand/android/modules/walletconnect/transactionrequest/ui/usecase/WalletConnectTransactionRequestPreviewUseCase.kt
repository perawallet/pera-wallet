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

package com.algorand.android.modules.walletconnect.transactionrequest.ui.usecase

import android.content.pm.PackageManager
import com.algorand.android.modules.walletconnect.transactionrequest.ui.mapper.WalletConnectTransactionRequestPreviewMapper
import com.algorand.android.modules.walletconnect.transactionrequest.ui.model.WalletConnectTransactionRequestPreview
import com.algorand.android.modules.walletconnectfallbackbrowser.domain.usecase.FallbackBrowserSelectionUseCase
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.mapper.WalletConnectFallbackBrowserItemMapper
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserListItem
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.usecase.GetInstalledAppPackageNameListUseCase
import javax.inject.Inject

class WalletConnectTransactionRequestPreviewUseCase @Inject constructor(
    private val fallbackBrowserSelectionUseCase: FallbackBrowserSelectionUseCase,
    private val walletConnectFallbackBrowserItemMapper: WalletConnectFallbackBrowserItemMapper,
    private val walletConnectTransactionRequestPreviewMapper: WalletConnectTransactionRequestPreviewMapper,
    private val getInstalledAppPackageNameListUseCase: GetInstalledAppPackageNameListUseCase
) {

    fun getInitialPreview(peerMetaName: String): WalletConnectTransactionRequestPreview {
        return walletConnectTransactionRequestPreviewMapper.mapToInitialPreview(peerMetaName)
    }

    suspend fun getWalletConnectTransactionRequestPreviewByBrowserResponse(
        preview: WalletConnectTransactionRequestPreview,
        fallbackBrowserGroupResponse: String?,
        packageManager: PackageManager?
    ): WalletConnectTransactionRequestPreview {
        val installedApplicationPackageNameList =
            getInstalledAppPackageNameListUseCase.getInstalledAppsPackageNameListOrEmpty(packageManager)
        val fallbackBrowserList =
            getFallbackBrowserList(installedApplicationPackageNameList, fallbackBrowserGroupResponse)
        return when {
            fallbackBrowserList == null || fallbackBrowserList.isEmpty() ->
                walletConnectTransactionRequestPreviewMapper.mapToNoFallbackBrowserFoundState(preview)
            fallbackBrowserList.size == 1 ->
                walletConnectTransactionRequestPreviewMapper.mapToSingleFallbackBrowserFoundState(
                    preview = preview,
                    browser = fallbackBrowserList.first()
                )
            else -> walletConnectTransactionRequestPreviewMapper.mapToMultipleFallbackBrowserFoundState(
                preview = preview,
                browserList = fallbackBrowserList
            )
        }
    }

    private suspend fun getFallbackBrowserList(
        installedApplicationPackageNameList: List<String>,
        fallbackBrowserGroupResponse: String?
    ): List<FallbackBrowserListItem>? {
        return fallbackBrowserGroupResponse?.let { browserGroup ->
            fallbackBrowserSelectionUseCase.getFilteredFallbackBrowserListByGroup(
                browserGroupResponse = browserGroup,
                installedApplicationPackageNameList = installedApplicationPackageNameList
            ).map { walletConnectFallbackBrowserItemMapper.mapTo(it) }
        }
    }
}
