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

package com.algorand.android.modules.walletconnect.launchback.transaction.ui.usecase

import android.content.Context
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.perapackagemanager.ui.PeraPackageManager
import com.algorand.android.modules.walletconnect.client.utils.WCTransactionLaunchBackDescriptionAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.launchback.base.domain.usecase.LaunchBackBrowserSelectionUseCase
import com.algorand.android.modules.walletconnect.launchback.base.ui.mapper.LaunchBackBrowserListItemMapper
import com.algorand.android.modules.walletconnect.launchback.base.ui.usecase.WcLaunchBackBrowserPreviewUseCase
import com.algorand.android.modules.walletconnect.launchback.transaction.ui.mapper.WcTransactionLaunchBackBrowserPreviewMapper
import com.algorand.android.modules.walletconnect.launchback.transaction.ui.model.WcTransactionLaunchBackBrowserPreview
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

class WcTransactionLaunchBackBrowserPreviewUseCase @Inject constructor(
    private val wcTransactionLaunchBackDescriptionAnnotatedStringProvider:
    WCTransactionLaunchBackDescriptionAnnotatedStringProvider,
    private val wcTransactionLaunchBackBrowserPreviewMapper: WcTransactionLaunchBackBrowserPreviewMapper,
    private val walletConnectManager: WalletConnectManager,
    peraPackageManager: PeraPackageManager,
    launchBackBrowserSelectionUseCase: LaunchBackBrowserSelectionUseCase,
    launchBackBrowserListItemMapper: LaunchBackBrowserListItemMapper,
    @ApplicationContext appContext: Context,
) : WcLaunchBackBrowserPreviewUseCase(
    appContext = appContext,
    peraPackageManager = peraPackageManager,
    launchBackBrowserSelectionUseCase = launchBackBrowserSelectionUseCase,
    launchBackBrowserListItemMapper = launchBackBrowserListItemMapper,
) {

    suspend fun getInitialWcTransactionLaunchBackBrowserPreview(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WcTransactionLaunchBackBrowserPreview {

        val sessionDetail = walletConnectManager.getWalletConnectSession(sessionIdentifier)
        val peerName = sessionDetail?.peerMeta?.name.orEmpty()
        val browserGroup = sessionDetail?.fallbackBrowserGroupResponse
        val launchBackBrowserList = createBrowserGroupList(browserGroup)
        val safeLaunchBackBrowserListSize = launchBackBrowserList?.size ?: 0
        val titleAnnotatedString = AnnotatedString(R.string.your_transaction_is_being_processed)
        val descriptionAnnotatedString =
            wcTransactionLaunchBackDescriptionAnnotatedStringProvider.provideDescriptionAnnotatedString(
                versionIdentifier = sessionIdentifier.versionIdentifier
            ).provideAnnotatedString(
                peerName = peerName,
                sessionIdentifier = sessionIdentifier
            )
        val primaryActionButtonAnnotatedString = createPrimaryActionButtonAnnotatedString(launchBackBrowserList)
        val secondaryButtonTextResId = createSecondaryActionButtonTextResId(safeLaunchBackBrowserListSize)

        return wcTransactionLaunchBackBrowserPreviewMapper.mapToWcTransactionLaunchBackBrowserPreview(
            iconResId = R.drawable.ic_info,
            iconTintResId = R.color.yellow_500,
            titleAnnotatedString = titleAnnotatedString,
            descriptionAnnotatedString = descriptionAnnotatedString,
            launchBackBrowserList = launchBackBrowserList,
            primaryActionButtonAnnotatedString = primaryActionButtonAnnotatedString,
            secondaryButtonTextResId = secondaryButtonTextResId
        )
    }
}
