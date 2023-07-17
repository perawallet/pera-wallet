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

package com.algorand.android.modules.walletconnect.launchback.connection.ui.usecase

import android.content.Context
import com.algorand.android.R
import com.algorand.android.modules.perapackagemanager.ui.PeraPackageManager
import com.algorand.android.modules.walletconnect.client.utils.WCConnectionLaunchBackDescriptionAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.client.utils.WCConnectionLaunchBackSessionInformationAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.client.utils.WCConnectionLaunchBackTitleAnnotatedStringProvider
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.launchback.base.domain.usecase.LaunchBackBrowserSelectionUseCase
import com.algorand.android.modules.walletconnect.launchback.base.ui.mapper.LaunchBackBrowserListItemMapper
import com.algorand.android.modules.walletconnect.launchback.base.ui.usecase.WcLaunchBackBrowserPreviewUseCase
import com.algorand.android.modules.walletconnect.launchback.connection.ui.mapper.WcConnectionLaunchBackBrowserPreviewMapper
import com.algorand.android.modules.walletconnect.launchback.connection.ui.model.WCConnectionLaunchBackBrowserPreview
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject

class WCConnectionLaunchBackBrowserPreviewUseCase @Inject constructor(
    private val walletConnectManager: WalletConnectManager,
    private val wcConnectionLaunchBackTitleAnnotatedStringProvider: WCConnectionLaunchBackTitleAnnotatedStringProvider,
    private val wcConnectionLaunchBackDescriptionAnnotatedStringProvider:
    WCConnectionLaunchBackDescriptionAnnotatedStringProvider,
    private val wcConnectionLaunchBackSessionInformationAnnotatedStringProvider:
    WCConnectionLaunchBackSessionInformationAnnotatedStringProvider,
    private val wcConnectionLaunchBackBrowserPreviewMapper: WcConnectionLaunchBackBrowserPreviewMapper,
    peraPackageManager: PeraPackageManager,
    launchBackBrowserSelectionUseCase: LaunchBackBrowserSelectionUseCase,
    launchBackBrowserListItemMapper: LaunchBackBrowserListItemMapper,
    @ApplicationContext appContext: Context
) : WcLaunchBackBrowserPreviewUseCase(
    peraPackageManager = peraPackageManager,
    launchBackBrowserSelectionUseCase = launchBackBrowserSelectionUseCase,
    launchBackBrowserListItemMapper = launchBackBrowserListItemMapper,
    appContext = appContext
) {

    suspend fun getInitialWcConnectionLaunchBackBrowserPreview(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WCConnectionLaunchBackBrowserPreview? {
        val sessionDetail = walletConnectManager.getWalletConnectSession(sessionIdentifier) ?: return null
        val browserGroup = sessionDetail.fallbackBrowserGroupResponse
        val launchBackBrowserList = createBrowserGroupList(browserGroup)
        val safeLaunchBackBrowserListSize = launchBackBrowserList?.size ?: 0

        val titleAnnotatedString = wcConnectionLaunchBackTitleAnnotatedStringProvider.provideTitleAnnotatedString(
            versionIdentifier = sessionIdentifier.versionIdentifier
        ).provideAnnotatedString(peerName = sessionDetail.peerMeta.name)

        val descriptionAnnotatedString =
            wcConnectionLaunchBackDescriptionAnnotatedStringProvider.provideDescriptionAnnotatedString(
                versionIdentifier = sessionIdentifier.versionIdentifier
            ).provideAnnotatedString(
                launchBackBrowserItemCount = safeLaunchBackBrowserListSize,
                sessionDetail = sessionDetail
            )

        val sessionInformationAnnotatedString =
            wcConnectionLaunchBackSessionInformationAnnotatedStringProvider.provideSessionInformationAnnotatedString(
                versionIdentifier = sessionIdentifier.versionIdentifier
            ).provideAnnotatedString(
                sessionDetail = sessionDetail
            )

        val primaryActionButtonAnnotatedString = createPrimaryActionButtonAnnotatedString(launchBackBrowserList)
        val secondaryButtonTextResId = createSecondaryActionButtonTextResId(safeLaunchBackBrowserListSize)

        return wcConnectionLaunchBackBrowserPreviewMapper.mapToWcConnectionLaunchBackBrowserPreview(
            iconTintResId = R.color.positive,
            iconResId = R.drawable.ic_check,
            titleAnnotatedString = titleAnnotatedString,
            descriptionAnnotatedString = descriptionAnnotatedString,
            launchBackBrowserList = launchBackBrowserList,
            primaryActionButtonAnnotatedString = primaryActionButtonAnnotatedString,
            secondaryButtonTextResId = secondaryButtonTextResId,
            sessionInformationAnnotatedString = sessionInformationAnnotatedString
        )
    }
}
