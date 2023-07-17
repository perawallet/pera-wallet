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

package com.algorand.android.modules.walletconnect.sessions.ui.mapper

import android.net.Uri
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.sessions.ui.decider.ConnectionStateDecider
import com.algorand.android.modules.walletconnect.sessions.ui.decider.SessionBadgeDecider
import com.algorand.android.modules.walletconnect.sessions.ui.decider.SessionDescriptionDecider
import com.algorand.android.modules.walletconnect.sessions.ui.model.BaseWalletConnectSessionItem
import com.algorand.android.modules.walletconnect.ui.mapper.WalletConnectSessionIdentifierMapper
import javax.inject.Inject

class BaseWalletConnectSessionItemMapper @Inject constructor(
    private val sessionIdentifierMapper: WalletConnectSessionIdentifierMapper,
    private val connectionStateDecider: ConnectionStateDecider,
    private val sessionBadgeDecider: SessionBadgeDecider,
    private val sessionDescriptionDecider: SessionDescriptionDecider
) {

    fun mapToWalletConnectSessionItem(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        dAppIconUrl: Uri?,
        dAppName: String,
        formattedConnectionDate: String,
        formattedExpirationDate: String?,
        isConnected: Boolean
    ): BaseWalletConnectSessionItem.WalletConnectSessionItem {
        return BaseWalletConnectSessionItem.WalletConnectSessionItem(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(
                sessionIdentifier = sessionIdentifier.getIdentifier(),
                versionIdentifier = sessionIdentifier.versionIdentifier
            ),
            dAppIconUrl = dAppIconUrl,
            dAppName = dAppName,
            descriptionAnnotatedString = sessionDescriptionDecider.decideSessionDescription(
                versionIdentifier = sessionIdentifier.versionIdentifier,
                formattedConnectionDate = formattedConnectionDate,
                formattedExpirationDate = formattedExpirationDate
            ),
            connectionState = mapToConnectionState(isConnected),
            sessionBadge = mapToSessionBadge(sessionIdentifier.versionIdentifier)
        )
    }

    private fun mapToConnectionState(
        isConnected: Boolean
    ): BaseWalletConnectSessionItem.WalletConnectSessionItem.ConnectionState {
        return with(connectionStateDecider) {
            BaseWalletConnectSessionItem.WalletConnectSessionItem.ConnectionState(
                stateName = decideConnectionStateName(isConnected),
                stateBackgroundColorResId = decideConnectionStateBackgroundColorResId(isConnected),
                stateBackgroundResId = decideConnectionStateBackgroundResId(isConnected),
                stateTextColorResId = decideConnectionStateTextColorResId(isConnected)
            )
        }
    }

    private fun mapToSessionBadge(
        versionIdentifier: WalletConnectVersionIdentifier
    ): BaseWalletConnectSessionItem.WalletConnectSessionItem.SessionBadge? {
        return with(sessionBadgeDecider) {
            BaseWalletConnectSessionItem.WalletConnectSessionItem.SessionBadge(
                badgeBackgroundColorResId = decideBadgeBackgroundColorResId(versionIdentifier) ?: return null,
                badgeBackgroundResId = decideBadgeBackgroundResId(versionIdentifier) ?: return null,
                badgeName = decideBadgeName(versionIdentifier) ?: return null,
                badgeTextColorResId = decideBadgeTextColorResId(versionIdentifier) ?: return null
            )
        }
    }
}
