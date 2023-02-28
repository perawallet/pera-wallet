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

package com.algorand.android.modules.walletconnect.sessions.ui.domain

import androidx.core.net.toUri
import com.algorand.android.R
import com.algorand.android.modules.walletconnect.domain.ConnectToExistingSessionUseCase
import com.algorand.android.modules.walletconnect.domain.KillAllWalletConnectSessionsUseCase
import com.algorand.android.modules.walletconnect.domain.KillWalletConnectSessionUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.sessions.ui.mapper.WalletConnectSessionItemMapper
import com.algorand.android.modules.walletconnect.sessions.ui.mapper.WalletConnectSessionsPreviewMapper
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionItem
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionsPreview
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.formatAsDateAndTime
import com.algorand.android.utils.getZonedDateTimeFromSec
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class WalletConnectSessionsPreviewUseCase @Inject constructor(
    private val killWalletConnectSessionUseCase: KillWalletConnectSessionUseCase,
    private val connectToExistingSessionUseCase: ConnectToExistingSessionUseCase,
    private val killAllWalletConnectSessionsUseCase: KillAllWalletConnectSessionsUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val walletConnectSessionsPreviewMapper: WalletConnectSessionsPreviewMapper,
    private val walletConnectSessionItemMapper: WalletConnectSessionItemMapper,
    private val walletConnectManager: WalletConnectManager
) {

    suspend fun killWalletConnectSession(sessionIdentifier: WalletConnectSessionIdentifier) {
        killWalletConnectSessionUseCase(sessionIdentifier)
    }

    suspend fun connectToExistingSession(sessionIdentifier: WalletConnectSessionIdentifier) {
        connectToExistingSessionUseCase(sessionIdentifier)
    }

    fun killAllWalletConnectSessions() {
        killAllWalletConnectSessionsUseCase()
    }

    fun getWalletConnectSessionsPreviewFlow(): Flow<WalletConnectSessionsPreview> {
        return walletConnectManager.localSessionsFlow.map {
            val walletConnectSessionList = createWalletConnectSessionList(it)
            walletConnectSessionsPreviewMapper.mapToWalletConnectSessionsPreview(
                walletConnectSessionList = walletConnectSessionList,
                isDisconnectAllSessionVisible = walletConnectSessionList.isNotEmpty(),
                isEmptyStateVisible = walletConnectSessionList.isEmpty()
            )
        }
    }

    private fun createWalletConnectSessionList(
        walletConnectSessions: List<WalletConnect.SessionDetail>,
    ): List<WalletConnectSessionItem> {
        return walletConnectSessions.map { walletConnectSession ->
            with(walletConnectSession) {
                walletConnectSessionItemMapper.mapToWalletConnectSessionItem(
                    sessionIdentifier = sessionIdentifier,
                    dAppLogoUrl = peerMeta.icons?.firstOrNull()?.toUri(),
                    dAppName = peerMeta.name,
                    dAppDescription = peerMeta.description,
                    connectionDate = getZonedDateTimeFromSec(creationDateTimestamp)?.formatAsDateAndTime(),
                    connectedAccountItems = createConnectedAccountItems(connectedAddresses, isConnected),
                    isConnected = isConnected,
                    isShowingDetails = true
                )
            }
        }
    }

    private fun createConnectedAccountItems(
        connectedAccounts: List<String>,
        isConnected: Boolean
    ): List<WalletConnectSessionItem.ConnectedSessionAccountItem> {
        val backgroundResource = if (isConnected) R.drawable.bg_connected_session_indicator else null
        val textColor = if (isConnected) R.color.link_primary else R.color.gray_400
        return connectedAccounts.map {
            walletConnectSessionItemMapper.mapToConnectedSessionAccountItem(
                backgroundResource = backgroundResource,
                textColor = textColor,
                displayName = accountDetailUseCase.getAccountName(it)
            )
        }
    }
}
