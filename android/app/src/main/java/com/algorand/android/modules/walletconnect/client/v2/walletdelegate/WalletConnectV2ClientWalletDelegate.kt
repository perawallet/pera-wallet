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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate

import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CreateWalletConnectProposalNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CreateWalletConnectSessionNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.GetWalletConnectV2LaunchBackBrowserGroupUseCase
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectWalletDelegateExceptions.MissingPeerMetaDataException.MissingPeerMetaDataExceptionInSessionSettle
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectV2ClientWalletDelegateMapperFacade
import com.algorand.android.utils.getCurrentTimeAsSec
import com.algorand.android.utils.launchIO
import com.walletconnect.android.Core
import com.walletconnect.sign.client.Sign
import com.walletconnect.sign.client.SignClient
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class WalletConnectV2ClientWalletDelegate @Inject constructor(
    private val walletDelegateMapperFacade: WalletConnectV2ClientWalletDelegateMapperFacade,
    private val createProposalNamespacesUseCase: CreateWalletConnectProposalNamespaceUseCase,
    private val createSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val getLaunchBackBrowserGroupUseCase: GetWalletConnectV2LaunchBackBrowserGroupUseCase
) : SignClient.WalletDelegate {

    private var walletDelegateListener: WalletConnectV2ClientWalletDelegateListener? = null

    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    fun setListener(listener: WalletConnectV2ClientWalletDelegateListener) {
        walletDelegateListener = listener
    }

    override fun onConnectionStateChange(state: Sign.Model.ConnectionState) {
        walletDelegateListener?.onConnectionChanged(state.isAvailable)
    }

    override fun onSessionDelete(deletedSession: Sign.Model.DeletedSession) {
        val sessionDelete = walletDelegateMapperFacade.mapToSessionDelete(deletedSession)
        walletDelegateListener?.onSessionDelete(sessionDelete)
    }

    override fun onSessionExtend(session: Sign.Model.Session) {
        // TODO: Implement this method.
    }

    override fun onSessionProposal(
        sessionProposal: Sign.Model.SessionProposal,
        verifyContext: Sign.Model.VerifyContext
    ) {
        coroutineScope.launchIO {
            val namespaces = createProposalNamespacesUseCase(sessionProposal)
            val fallbackBrowserUrl = getLaunchBackBrowserGroupUseCase(sessionProposal.pairingTopic)
            val proposal =
                walletDelegateMapperFacade.mapToSessionProposal(sessionProposal, namespaces, fallbackBrowserUrl)
            walletDelegateListener?.onSessionProposal(proposal)
        }
    }

    override fun onSessionUpdateResponse(sessionUpdateResponse: Sign.Model.SessionUpdateResponse) {
        val sessionUpdate = walletDelegateMapperFacade.mapToSessionUpdate(sessionUpdateResponse)
        walletDelegateListener?.onSessionUpdate(sessionUpdate)
    }

    override fun onSessionRequest(sessionRequest: Sign.Model.SessionRequest, verifyContext: Sign.Model.VerifyContext) {
        val sessionPeerMeta = sessionRequest.peerMetaData
        if (sessionPeerMeta != null) {
            val peerMeta = walletDelegateMapperFacade.mapToPeerMeta(sessionPeerMeta)
            val sessionRequestData = walletDelegateMapperFacade.mapToSessionRequest(sessionRequest, peerMeta)
            walletDelegateListener?.onSessionRequest(sessionRequestData)
        }
    }

    override fun onSessionSettleResponse(settleSessionResponse: Sign.Model.SettledSessionResponse) {
        when (settleSessionResponse) {
            is Sign.Model.SettledSessionResponse.Result -> {
                val sessionPeerMeta = settleSessionResponse.session.metaData
                if (sessionPeerMeta == null) {
                    onSessionSettleResponseFail(settleSessionResponse.session.topic)
                } else {
                    onSessionSettleResponseSuccess(settleSessionResponse, sessionPeerMeta)
                }
            }

            is Sign.Model.SettledSessionResponse.Error -> {
                val sessionSettleError = walletDelegateMapperFacade.mapToSessionSettleError(settleSessionResponse)
                walletDelegateListener?.onSessionSettleFail(sessionSettleError)
            }
        }
    }

    private fun onSessionSettleResponseSuccess(
        settleSessionResponse: Sign.Model.SettledSessionResponse.Result,
        sessionPeerMeta: Core.Model.AppMetaData
    ) {
        coroutineScope.launchIO {
            val fallbackBrowserGroupResponse = getLaunchBackBrowserGroupUseCase(
                settleSessionResponse.session.pairingTopic
            )
            val sessionSettleSuccess = walletDelegateMapperFacade.mapToSessionSettleSuccess(
                settleSessionResponse = settleSessionResponse,
                peerMeta = walletDelegateMapperFacade.mapToPeerMeta(sessionPeerMeta),
                namespaces = createSessionNamespaceUseCase(settleSessionResponse.session),
                creationDateTimestamp = getCurrentTimeAsSec(),
                isConnected = true,
                fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
            )
            walletDelegateListener?.onSessionSettleSuccess(sessionSettleSuccess)
        }
    }

    private fun onSessionSettleResponseFail(sessionTopic: String) {
        val missingPeerMetaException = MissingPeerMetaDataExceptionInSessionSettle(
            sessionTopic = sessionTopic,
            message = null
        )
        val sessionSettleFailError = walletDelegateMapperFacade.mapToSessionSettleError(
            sessionTopic = sessionTopic,
            throwable = missingPeerMetaException
        )
        walletDelegateListener?.onSessionSettleFail(sessionSettleFailError)
    }

    override fun onError(error: Sign.Model.Error) {
        val genericError = walletDelegateMapperFacade.mapToError(error)
        walletDelegateListener?.onError(genericError)
    }
}
