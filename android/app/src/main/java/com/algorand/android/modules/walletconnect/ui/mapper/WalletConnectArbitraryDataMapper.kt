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

package com.algorand.android.modules.walletconnect.ui.mapper

import com.algorand.android.mapper.WalletConnectArbitraryDataMapper
import com.algorand.android.models.WCArbitraryData
import com.algorand.android.models.WalletConnectArbitraryData
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.google.gson.Gson
import javax.inject.Inject

class WalletConnectArbitraryDataMapper @Inject constructor(
    private val arbitraryDataMapper: WalletConnectArbitraryDataMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val sessionIdentifierMapper: WalletConnectSessionIdentifierMapper,
    private val gson: Gson
) {

    fun parseArbitraryDataPayload(payload: List<*>): List<WCArbitraryData>? {
        return try {
            payload.map { rawArbitraryData ->
                gson.fromJson(gson.toJson(rawArbitraryData), WCArbitraryData::class.java)
            }
        } catch (exception: Exception) {
            null
        }
    }

    fun createWalletConnectArbitraryData(
        peerMeta: WalletConnect.PeerMeta,
        arbitraryData: WCArbitraryData
    ): WalletConnectArbitraryData? {
        val walletConnectPeerMeta = peerMetaMapper.mapToPeerMeta(peerMeta)
        return arbitraryDataMapper.createWalletConnectArbitraryData(walletConnectPeerMeta, arbitraryData)
    }

    fun mapToWalletConnectSession(session: WalletConnect.SessionDetail): WalletConnectSession {
        return WalletConnectSession(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(
                session.sessionIdentifier.getIdentifier(),
                session.versionIdentifier
            ),
            peerMeta = peerMetaMapper.mapToPeerMeta(session.peerMeta),
            dateTimeStamp = session.creationDateTimestamp,
            isConnected = session.isConnected,
            connectedAccountsAddresses = session.connectedAccounts.map { it.accountAddress },
            fallbackBrowserGroupResponse = session.fallbackBrowserGroupResponse,
        )
    }
}
