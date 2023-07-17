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

package com.algorand.android.modules.walletconnect.client.utils.uiprovider.sessiondetail

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier.VERSION_1
import com.algorand.android.modules.walletconnect.sessiondetail.ui.model.WalletConnectSessionDetailPreview
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewCheckSessionStatusProvider
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewInformationBadgeProvider
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewStateProvider
import com.algorand.android.modules.walletconnect.sessiondetail.ui.usecase.WalletConnectSessionDetailPreviewVisibilityProvider
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import javax.inject.Inject

class WalletConnectSessionDetailPreviewStateProviderImpl @Inject constructor(
    private val wcV1SessionDetailPreviewStateProvider: WalletConnectSessionDetailPreviewVisibilityProvider,
    private val wcV2SessionDetailPreviewStateProvider: WalletConnectSessionDetailPreviewVisibilityProvider,
    private val wcV2CheckSessionStatusProvider: WalletConnectSessionDetailPreviewCheckSessionStatusProvider,
    private val wcV1InformationBadgeProvider: WalletConnectSessionDetailPreviewInformationBadgeProvider
) : WalletConnectSessionDetailPreviewStateProvider {

    override fun isExtendExpirationDateButtonVisible(sessionIdentifier: WalletConnectSessionIdentifier): Boolean {
        return getSessionDetailPreviewVisibilityProvider(sessionIdentifier)
            .isExtendExpirationDateButtonVisible(sessionIdentifier)
    }

    override suspend fun isExtendExpirationDateButtonEnabled(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): Boolean {
        return getSessionDetailPreviewVisibilityProvider(sessionIdentifier)
            .isExtendExpirationDateButtonEnabled(sessionIdentifier)
    }

    override fun getInformationBadgeDetail(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.InformationBadge? {
        return if (sessionIdentifier.versionIdentifier == VERSION_1) {
            wcV1InformationBadgeProvider.getInformationBadgeDetail(sessionIdentifier)
        } else {
            null
        }
    }

    override fun getInitialCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus? {
        return getSessionDetailPreviewCheckSessionStatusProvider(sessionIdentifier)
            ?.getInitialCheckSessionStatus(sessionIdentifier)
    }

    override fun getLoadingStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus? {
        return getSessionDetailPreviewCheckSessionStatusProvider(sessionIdentifier)
            ?.getLoadingStateForCheckSessionStatus(sessionIdentifier)
    }

    override fun getSuccessStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus? {
        return getSessionDetailPreviewCheckSessionStatusProvider(sessionIdentifier)
            ?.getSuccessStateForCheckSessionStatus(sessionIdentifier)
    }

    override fun getErrorStateForCheckSessionStatus(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreview.CheckSessionStatus? {
        return getSessionDetailPreviewCheckSessionStatusProvider(sessionIdentifier)
            ?.getErrorStateForCheckSessionStatus(sessionIdentifier)
    }

    private fun getSessionDetailPreviewCheckSessionStatusProvider(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreviewCheckSessionStatusProvider? {
        return when (sessionIdentifier.versionIdentifier) {
            VERSION_1 -> null
            WalletConnectVersionIdentifier.VERSION_2 -> wcV2CheckSessionStatusProvider
        }
    }

    private fun getSessionDetailPreviewVisibilityProvider(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnectSessionDetailPreviewVisibilityProvider {
        return when (sessionIdentifier.versionIdentifier) {
            VERSION_1 -> wcV1SessionDetailPreviewStateProvider
            WalletConnectVersionIdentifier.VERSION_2 -> wcV2SessionDetailPreviewStateProvider
        }
    }

    companion object {
        const val INJECTION_NAME = "walletConnectSessionDetailPreviewStateProviderImplInjectionName"
    }
}
