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

package com.algorand.android.modules.walletconnect.client.v2

import android.app.Application
import android.util.Log
import com.algorand.android.modules.walletconnect.client.utils.WalletConnectClientErrorMessageUtils.createDappErrorMessage
import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.client.v2.domain.repository.WalletConnectV2Repository
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CacheWalletConnectV2PairUriUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.CreateWalletConnectSessionNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v2.domain.usecase.RemoveAccountFromV2SessionUseCase
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectClientV2Mapper
import com.algorand.android.modules.walletconnect.client.v2.serverstatus.WalletConnectV2SessionServerStatusManager
import com.algorand.android.modules.walletconnect.client.v2.sessionexpiration.WalletConnectV2SessionExpirationManager
import com.algorand.android.modules.walletconnect.client.v2.utils.InitializeWalletConnectV2ClientUseCase
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectClientV2Utils
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2CaipUseCase
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2ErrorCodeProvider
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectWalletDelegateExceptions.MissingPeerMetaDataException.MissingPeerMetaDataExceptionInSessionSettle
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.WalletConnectV2ClientWalletDelegate
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.WalletConnectV2ClientWalletDelegateListener
import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.domain.WalletConnectSessionExpirationManager
import com.algorand.android.modules.walletconnect.domain.WalletConnectSessionServerStatusManager
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectClientListener
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectError
import com.algorand.android.utils.launchIO
import com.google.gson.Gson
import com.walletconnect.android.Core
import com.walletconnect.android.CoreClient
import javax.inject.Named
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

@Suppress("TooManyFunctions", "LongParameterList")
class WalletConnectClientV2Impl(
    private val clientV2Mapper: WalletConnectClientV2Mapper,
    private val errorCodeProvider: WalletConnectV2ErrorCodeProvider,
    @Named(WalletConnectV2Repository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectV2Repository,
    private val createSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val caipUseCase: WalletConnectV2CaipUseCase,
    private val initializeClientUseCase: InitializeWalletConnectV2ClientUseCase,
    private val removeAccountFromSessionUseCase: RemoveAccountFromV2SessionUseCase,
    private val signClient: WalletConnectV2SignClient,
    private val walletDelegate: WalletConnectV2ClientWalletDelegate,
    private val cachePairUriUseCase: CacheWalletConnectV2PairUriUseCase,
    private val sessionExpirationManager: WalletConnectV2SessionExpirationManager,
    private val sessionServerStatusManager: WalletConnectV2SessionServerStatusManager,
    private val gson: Gson // TODO Use wrapper after merging this branch with ASB
) : WalletConnectClient,
    WalletConnectSessionExpirationManager by sessionExpirationManager,
    WalletConnectSessionServerStatusManager by sessionServerStatusManager {

    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isSocketConnectionOpen: Boolean = false

    private var walletConnectClientListener: WalletConnectClientListener? = null

    private val walletDelegateListener = object : WalletConnectV2ClientWalletDelegateListener {

        override fun onSessionProposal(proposal: WalletConnect.Session.Proposal) {
            walletConnectClientListener?.onSessionProposal(proposal)
        }

        override fun onSessionUpdate(update: WalletConnect.Session.Update) {
            walletConnectClientListener?.onSessionUpdate(update)
        }

        override fun onSessionDelete(delete: WalletConnect.Session.Delete) {
            walletConnectClientListener?.onSessionDelete(delete)
        }

        override fun onSessionSettleSuccess(settle: WalletConnect.Session.Settle.Result) {
            insertSettledSessionToDb(settle)
            walletConnectClientListener?.onSessionSettle(settle)
        }

        override fun onSessionSettleFail(error: WalletConnect.Session.Settle.Error) {
            if (error.throwable is MissingPeerMetaDataExceptionInSessionSettle && error.sessionIdentifier != null) {
                coroutineScope.launchIO {
                    killSession(error.sessionIdentifier)
                }
            }
        }

        override fun onSessionRequest(sessionRequest: WalletConnect.Model.SessionRequest) {
            walletConnectClientListener?.onSessionRequest(sessionRequest)
        }

        override fun onConnectionChanged(isAvailable: Boolean) {
            isSocketConnectionOpen = isAvailable
            coroutineScope.launchIO {
                getAllSessionDetails().forEach { sessionDetail ->
                    val connectionState =
                        clientV2Mapper.mapToConnectionState(sessionDetail, isSocketConnectionOpen, null)
                    walletConnectClientListener?.onConnectionChanged(connectionState)
                }
            }
        }

        override fun onError(error: WalletConnect.Model.Error) {
            walletConnectClientListener?.onError(error)
        }
    }

    override suspend fun initializeClient(application: Application) {
        initializeClientUseCase(application)
        walletDelegate.setListener(walletDelegateListener)
        signClient.setWalletDelegate(walletDelegate)
    }

    override fun setListener(listener: WalletConnectClientListener) {
        walletConnectClientListener = listener
    }

    override fun connect(uri: String) {
        coroutineScope.launchIO {
            cachePairUriUseCase(uri)
            val pair = clientV2Mapper.mapToPair(uri)
            CoreClient.Pairing.pair(pair)
        }
    }

    override suspend fun approveSession(
        proposalIdentifier: WalletConnect.Session.ProposalIdentifier,
        requiredNamespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>,
        accountAddresses: List<String>
    ) {
        val accountListAsCaip = caipUseCase.create(accountAddresses, requiredNamespaces)
        val proposalPublicKey = proposalIdentifier.getIdentifier()
        val chainListAsCaip = mutableMapOf<String, List<String>>().apply {
            requiredNamespaces.forEach { (blockchain, namespace) ->
                val chainList = namespace.chains.map {
                    caipUseCase.mergeBlockchainAndChains(blockchain, it)
                }
                put(blockchain.value, chainList)
            }
        }
        val approveProposal = clientV2Mapper.mapToSessionApprove(
            proposerPublicKey = proposalPublicKey,
            accountListAsCaip = accountListAsCaip,
            namespaces = requiredNamespaces,
            chainListAsCaip = chainListAsCaip
        )
        signClient.approveSession(approveProposal)
    }

    override suspend fun updateSession(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        accountAddresses: List<String>,
        removedAccountAddress: String?
    ) {
        val session = getWalletConnectSession(sessionIdentifier) ?: return
        removeAccountFromSessionUseCase(session, removedAccountAddress ?: return)
    }

    override suspend fun rejectSession(proposalIdentifier: WalletConnect.Session.ProposalIdentifier, reason: String) {
        val rejectSession = clientV2Mapper.mapToSessionReject(proposalIdentifier, reason)
        signClient.rejectSession(rejectSession)
    }

    override suspend fun rejectRequest(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        errorResponse: WalletConnectError
    ) {
        rejectRequest(sessionIdentifier.getIdentifier(), requestIdentifier.getIdentifier(), errorResponse)
    }

    private fun rejectRequest(sessionTopic: String, requestId: Long, errorResponse: WalletConnectError) {
        val errorCode = errorCodeProvider.getErrorCode(errorResponse.reason)
        val errorMessage = createDappErrorMessage(errorResponse, errorCode)
        val rejectRequest = clientV2Mapper.mapToRequestReject(
            sessionTopic = sessionTopic,
            requestId = requestId,
            errorCode = errorCode.toInt(),
            errorMessage = errorMessage
        )
        signClient.respond(rejectRequest)
    }

    override suspend fun approveRequest(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        payload: Any
    ) {
        val approveRequest = clientV2Mapper.mapToRequestApprove(
            sessionIdentifier = sessionIdentifier,
            requestIdentifier = requestIdentifier,
            payload = gson.toJson(payload)
        )
        signClient.respond(approveRequest)
    }

    override fun getDefaultChainIdentifier(): WalletConnect.ChainIdentifier {
        return WalletConnect.ChainIdentifier.MAINNET
    }

    override fun isValidSessionUrl(url: String): Boolean {
        return WalletConnectClientV2Utils.isValidWalletConnectV2Url(url)
    }

    override suspend fun killSession(sessionIdentifier: WalletConnect.SessionIdentifier) {
        val killSession = clientV2Mapper.mapToSessionDisconnect(sessionIdentifier)
        signClient.disconnect(killSession)
        // TODO use success callback after updating WC v2 lib version
        val deleteSuccess = clientV2Mapper.mapToSessionDeleteSuccess(sessionIdentifier, "")
        walletConnectClientListener?.onSessionDelete(deleteSuccess)
    }

    override suspend fun getWalletConnectSession(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): WalletConnect.SessionDetail? {
        val actionSession = signClient.getActiveSessionByTopic(sessionIdentifier.getIdentifier()) ?: return null
        val sessionDto = walletConnectRepository.getSessionById(sessionIdentifier.getIdentifier()) ?: return null
        val namespaces = createSessionNamespaceUseCase(actionSession)
        return clientV2Mapper.mapToSessionDetail(actionSession, sessionDto, namespaces, isSocketConnectionOpen)
    }

    override suspend fun getAllWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return getAllSessionDetails()
    }

    override suspend fun getSessionsByAccountAddress(accountAddress: String): List<WalletConnect.SessionDetail> {
        return getAllSessionDetails().filter { sessionDetail ->
            sessionDetail.namespaces.values.any { sessionNamespace ->
                sessionNamespace.accounts.any { it.accountAddress == accountAddress }
            }
        }
    }

    override suspend fun getDisconnectedWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return if (isSocketConnectionOpen) emptyList() else getAllSessionDetails()
    }

    private suspend fun getAllSessionDetails(): List<WalletConnect.SessionDetail> {
        val activeSessions = signClient.getListOfActiveSessions()
        val localSessionDtos = walletConnectRepository.getWCSessionList().toMutableList()
        return activeSessions.mapNotNull { session ->
            val localSessionDto = localSessionDtos.firstOrNull { it.topic == session.topic } ?: return@mapNotNull null
            val namespaces = createSessionNamespaceUseCase(session)
            localSessionDtos.remove(localSessionDto)
            clientV2Mapper.mapToSessionDetail(session, localSessionDto, namespaces, isSocketConnectionOpen)
        }
    }

    override suspend fun connectToDisconnectedSessions() {
        CoreClient.Relay.connect { error: Core.Model.Error -> logError(error.throwable.stackTraceToString()) }
    }

    override suspend fun disconnectFromAllSessions() {
        CoreClient.Relay.disconnect { error: Core.Model.Error -> logError(error.throwable.stackTraceToString()) }
    }

    private fun insertSettledSessionToDb(settle: WalletConnect.Session.Settle.Result) {
        coroutineScope.launchIO {
            walletConnectRepository.insertWalletConnectSession(
                WalletConnectSessionDto(
                    topic = settle.session.topic,
                    creationDateTimestamp = settle.session.creationDateTimestamp,
                    fallbackBrowserGroupResponse = settle.session.fallbackBrowserGroupResponse
                )
            )
        }
    }

    private fun logError(message: String) {
        Log.e(logTag, message)
    }

    // region Unused functions
    override suspend fun connect(sessionIdentifier: WalletConnect.SessionIdentifier) {
        return
    }

    override suspend fun setAllSessionsDisconnected() {
        // Since we don't keep wc v2 session status in db, nothing to do here.
    }
    // endregion

    companion object {
        private val logTag = WalletConnectClientV2Impl::class.simpleName
        const val INJECTION_NAME = "walletConnectClientV2InjectionName"
    }
}
