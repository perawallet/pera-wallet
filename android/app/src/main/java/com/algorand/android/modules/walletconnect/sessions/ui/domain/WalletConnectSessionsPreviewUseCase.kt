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
import com.algorand.android.modules.walletconnect.connectedapps.ui.mapper.WalletConnectSessionItemMapper
import com.algorand.android.modules.walletconnect.domain.ConnectToExistingSessionUseCase
import com.algorand.android.modules.walletconnect.domain.KillAllWalletConnectSessionsUseCase
import com.algorand.android.modules.walletconnect.domain.KillWalletConnectSessionUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.sessions.ui.mapper.BaseWalletConnectSessionItemMapper
import com.algorand.android.modules.walletconnect.sessions.ui.mapper.WalletConnectSessionsPreviewMapper
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem
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
    private val walletConnectManager: WalletConnectManager,
    private val baseWalletConnectSessionItemMapper: BaseWalletConnectSessionItemMapper
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
                waseWalletConnectSessionItemList = walletConnectSessionList,
                isDisconnectAllSessionVisible = walletConnectSessionList.isNotEmpty(),
                isEmptyStateVisible = walletConnectSessionList.isEmpty()
            )
        }
    }

    private fun createWalletConnectSessionList(
        walletConnectSessions: List<WalletConnect.SessionDetail>,
    ): List<BaseWalletConnectSessionItem> {
        return walletConnectSessions.map { walletConnectSession ->
            baseWalletConnectSessionItemMapper.mapToWalletConnectSessionItem(
                sessionIdentifier = walletConnectSession.sessionIdentifier,
                dAppIconUrl = walletConnectSession.peerMeta.icons?.firstOrNull()?.toUri(),
                dAppName = walletConnectSession.peerMeta.name,
                formattedConnectionDate = getZonedDateTimeFromSec(
                    sec = walletConnectSession.creationDateTimestamp
                ).formatAsDateAndTime(),
                formattedExpirationDate = walletConnectSession.expiry?.seconds?.let { expirationDate ->
                    getZonedDateTimeFromSec(expirationDate).formatAsDateAndTime()
                },
                isConnected = walletConnectSession.isConnected
            )
        }
    }
}
