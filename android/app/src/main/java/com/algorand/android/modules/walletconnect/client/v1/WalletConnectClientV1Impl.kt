@file:SuppressWarnings("TooManyFunctions")

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

package com.algorand.android.modules.walletconnect.client.v1

import android.app.Application
import com.algorand.android.modules.walletconnect.client.utils.WalletConnectClientErrorMessageUtils.createDappErrorMessage
import com.algorand.android.modules.walletconnect.client.utils.WalletConnectSessionNotFoundException
import com.algorand.android.modules.walletconnect.client.v1.domain.decider.WalletConnectV1ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.CreateWalletConnectProposalNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.CreateWalletConnectSessionNamespaceUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.DeleteWalletConnectAccountBySessionUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetConnectedAccountsOfWalletConnectSessionUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetDisconnectedWalletConnectSessionsUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectSessionsByAccountAddressUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectSessionsOrderedByCreationUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.GetWalletConnectV1SessionCountUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.InsertWalletConnectV1SessionToDBUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.WalletConnectV1SessionRequestIdValidationUseCase
import com.algorand.android.modules.walletconnect.client.v1.domain.usecase.WalletConnectV1TransactionRequestIdValidationUseCase
import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectClientV1Mapper
import com.algorand.android.modules.walletconnect.client.v1.retrycount.WalletConnectV1SessionRetryCounter
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectSessionBuilder
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedData
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedDataHandler
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectClientV1Utils
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1ErrorCodeProvider
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1IdentifierParser
import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.ChainIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.SessionIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectClientListener
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectError
import com.algorand.android.utils.exception.InvalidWalletConnectUrlException
import com.algorand.android.utils.getCurrentTimeAsSec
import com.algorand.android.utils.launchIO
import com.algorand.android.utils.recordException
import com.algorand.android.utils.walletconnect.WalletConnectSessionRetryCounter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import org.walletconnect.Session
import org.walletconnect.impls.WCSession
import javax.inject.Named

@Suppress("LongParameterList")
class WalletConnectClientV1Impl(
    private val sessionBuilder: WalletConnectSessionBuilder,
    private val walletConnectMapper: WalletConnectClientV1Mapper,
    private val errorCodeProvider: WalletConnectV1ErrorCodeProvider,
    private val sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler,
    @Named(WalletConnectRepository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectRepository,
    private val getConnectedAccountsOfWalletConnectSessionUseCase: GetConnectedAccountsOfWalletConnectSessionUseCase,
    private val getWalletConnectSessionsByAccountAddressUseCase: GetWalletConnectSessionsByAccountAddressUseCase,
    private val insertWalletConnectV1SessionToDBUseCase: InsertWalletConnectV1SessionToDBUseCase,
    private val getDisconnectedWalletConnectSessionsUseCase: GetDisconnectedWalletConnectSessionsUseCase,
    private val identifierParser: WalletConnectV1IdentifierParser,
    private val chainIdentifierDecider: WalletConnectV1ChainIdentifierDecider,
    private val createWalletConnectSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val createWalletConnectProposalNamespaceUseCase: CreateWalletConnectProposalNamespaceUseCase,
    private val deleteWalletConnectAccountBySessionUseCase: DeleteWalletConnectAccountBySessionUseCase,
    private val getWalletConnectSessionsOrderedByCreationUseCase: GetWalletConnectSessionsOrderedByCreationUseCase,
    private val getWalletConnectV1SessionCountUseCase: GetWalletConnectV1SessionCountUseCase,
    private val walletConnectSessionRetryCounter: WalletConnectV1SessionRetryCounter,
    private val sessionRequestIdValidationUseCase: WalletConnectV1SessionRequestIdValidationUseCase,
    private val transactionRequestIdValidationUseCase: WalletConnectV1TransactionRequestIdValidationUseCase
) : WalletConnectClient, WalletConnectSessionRetryCounter by walletConnectSessionRetryCounter {

    private var listener: WalletConnectClientListener? = null

    private val coroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private val sessionCacheDataCallback = object : WalletConnectV1SessionCachedData.Callback {
        override fun onSessionRequest(
            cachedData: WalletConnectV1SessionCachedData,
            requestId: Long,
            call: Session.MethodCall.SessionRequest,
            chainId: Long?
        ) {
            processSessionRequest(requestId, cachedData, call, chainId)
        }

        override fun onSessionUpdate(
            cachedData: WalletConnectV1SessionCachedData,
            call: Session.MethodCall.SessionUpdate
        ) {
            val sessionUpdate = walletConnectMapper.mapToSessionUpdateSuccess(cachedData.sessionId)
            listener?.onSessionUpdate(sessionUpdate)

            if (!call.params.approved) {
                listener?.onSessionDelete(walletConnectMapper.mapToSessionDeleteSuccess(cachedData.sessionId, ""))
            }
        }

        override fun onCustomRequest(cachedData: WalletConnectV1SessionCachedData, call: Session.MethodCall.Custom) {
            processTransactionRequest(cachedData, call)
        }

        override fun onSessionConnected(cachedData: WalletConnectV1SessionCachedData, clientId: String) {
            coroutineScope.launchIO {
                val sessionDetail = getSessionFromDBOrLogIfNotFound(
                    sessionId = cachedData.sessionId,
                    funcName = javaClass.enclosingMethod?.name
                ) ?: return@launchIO
                val connectionState = walletConnectMapper.mapToConnectionState(
                    sessionDetail = sessionDetail,
                    isConnected = true,
                    clientId = clientId
                )
                walletConnectRepository.setConnectedSession(cachedData.sessionId)
                listener?.onConnectionChanged(connectionState)
            }
        }

        override fun onSessionDisconnected(cachedData: WalletConnectV1SessionCachedData, isDeletionNeeded: Boolean) {
            coroutineScope.launchIO {
                val sessionDetail = getSessionFromDBOrLogIfNotFound(
                    sessionId = cachedData.sessionId,
                    funcName = javaClass.enclosingMethod?.name
                ) ?: return@launchIO
                walletConnectRepository.setSessionDisconnected(cachedData.sessionId)
                val connectionState = walletConnectMapper.mapToConnectionState(
                    sessionDetail = sessionDetail,
                    isConnected = false,
                    clientId = null
                )
                listener?.onConnectionChanged(connectionState)
            }
        }

        override fun onSessionApproved(cachedData: WalletConnectV1SessionCachedData, clientId: String) {
            coroutineScope.launchIO {
                val settle = walletConnectMapper.mapToSettleSuccess(
                    cachedData = cachedData,
                    namespaces = createWalletConnectSessionNamespaceUseCase.invoke(
                        accountAddresses = cachedData.approvedAccounts,
                        chainId = cachedData.session.chainId
                    ),
                    creationDateTimestamp = getCurrentTimeAsSec(),
                    expiry = null,
                    isConnected = true,
                    clientId = clientId
                )
                insertWalletConnectV1SessionToDBUseCase(settle)
                walletConnectSessionRetryCounter.clearSessionRetryCount(cachedData.sessionId)
                listener?.onSessionSettle(settle)
            }
        }

        override fun onSessionError(cachedData: WalletConnectV1SessionCachedData, error: Session.Status.Error) {
            val sessionError = walletConnectMapper.mapToSessionError(cachedData.sessionId, error.throwable)
            listener?.onSessionError(sessionError)
        }

        override fun onSessionKilled(cachedData: WalletConnectV1SessionCachedData) {
            coroutineScope.launchIO {
                deleteSessionFromCacheById(cachedData.sessionId)
                deleteSessionFromDbById(cachedData.sessionId)
                val delete = walletConnectMapper.mapToSessionDeleteSuccess(cachedData.sessionId, "")
                listener?.onSessionDelete(delete)
            }
        }
    }

    override fun setListener(listener: WalletConnectClientListener) {
        this.listener = listener
    }

    override fun connect(uri: String) {
        val session = sessionBuilder.createSession(uri) ?: run {
            val error = walletConnectMapper.mapToError(InvalidWalletConnectUrlException, null)
            listener?.onError(error)
            return
        }
        connectToSession(session)
    }

    override suspend fun connect(sessionIdentifier: SessionIdentifier) {
        identifierParser.withSessionId(sessionIdentifier) { id ->
            val sessionEntity = walletConnectRepository.getSessionById(id)
            val sessionMeta = sessionEntity?.wcSession ?: return@withSessionId
            val session = sessionBuilder.createSession(
                sessionId = id,
                sessionMeta = sessionMeta,
                fallbackBrowserGroupResponse = sessionEntity.fallbackBrowserGroupResponse
            ) ?: return@withSessionId
            connectToSession(session)
        }
    }

    override suspend fun approveSession(
        proposalIdentifier: WalletConnect.Session.ProposalIdentifier,
        requiredNamespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>,
        accountAddresses: List<String>
    ) {
        identifierParser.withProposalIdentifier(proposalIdentifier) { sessionId ->
            val chainIdentifier = requiredNamespaces.values.first().chains.firstOrNull()
            val chainId = chainIdentifierDecider.decideChainId(chainIdentifier ?: getDefaultChainIdentifier())
            getSessionById(sessionId)?.approve(accountAddresses, chainId)
        }
    }

    override suspend fun updateSession(
        sessionIdentifier: SessionIdentifier,
        accountAddresses: List<String>,
        removedAccountAddress: String?
    ) {
        identifierParser.withSessionId(sessionIdentifier) { sessionId ->
            val chainId = chainIdentifierDecider.decideChainId(getDefaultChainIdentifier())
            getSessionById(sessionId)?.update(accountAddresses, chainId)
            if (removedAccountAddress != null) {
                deleteWalletConnectAccountBySessionUseCase(sessionId, removedAccountAddress)
            }
        }
    }

    override suspend fun rejectSession(proposalIdentifier: WalletConnect.Session.ProposalIdentifier, reason: String) {
        identifierParser.withProposalIdentifier(proposalIdentifier) { id ->
            getSessionById(id)?.reject()
            deleteSessionFromCacheById(id)
        }
    }

    override suspend fun rejectRequest(
        sessionIdentifier: SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        errorResponse: WalletConnectError
    ) {
        identifierParser.withSessionId(sessionIdentifier) { sessionId ->
            identifierParser.withRequestId(requestIdentifier) { requestId ->
                val errorResponseCode = errorCodeProvider.getErrorCode(errorResponse.reason)
                val errorMessage = createDappErrorMessage(errorResponse, errorResponseCode)
                getSessionById(sessionId)?.rejectRequest(requestId, errorResponseCode, errorMessage)
            }
        }
    }

    override suspend fun approveRequest(
        sessionIdentifier: SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        payload: Any
    ) {
        identifierParser.withSessionId(sessionIdentifier) { sessionId ->
            identifierParser.withRequestId(requestIdentifier) { requestId ->
                getSessionById(sessionId)?.approveRequest(requestId, payload)
            }
        }
    }

    override fun getDefaultChainIdentifier(): ChainIdentifier {
        return DEFAULT_CHAIN_IDENTIFIER_FOR_V1
    }

    override fun isValidSessionUrl(url: String): Boolean {
        return WalletConnectClientV1Utils.isValidWalletConnectUrl(url)
    }

    override suspend fun killSession(sessionIdentifier: SessionIdentifier) {
        identifierParser.withSessionId(sessionIdentifier) { id ->
            getSessionById(id)?.kill()
            deleteSessionFromCacheById(id)
            deleteSessionFromDbById(id)
            listener?.onSessionDelete(walletConnectMapper.mapToSessionDeleteSuccess(sessionIdentifier, ""))
        }
    }

    override suspend fun getWalletConnectSession(sessionIdentifier: SessionIdentifier): WalletConnect.SessionDetail? {
        return identifierParser.withSessionId(sessionIdentifier) { id ->
            getWalletConnectSession(id)
        }
    }

    private suspend fun getWalletConnectSession(sessionId: Long): WalletConnect.SessionDetail? {
        val sessionEntity = walletConnectRepository.getSessionById(sessionId) ?: return null
        val walletConnectSessionAccountDto = getConnectedAccountsOfWalletConnectSessionUseCase(sessionId).map {
            it.connectedAccountsAddress
        }
        val wcSession = getSessionById(sessionId)
        return walletConnectMapper.mapToSessionDetail(
            entity = sessionEntity,
            creationDateTimestamp = sessionEntity.dateTimeStamp,
            fallbackBrowserGroupResponse = sessionEntity.fallbackBrowserGroupResponse,
            namespaces = createWalletConnectSessionNamespaceUseCase.invoke(
                accountAddresses = walletConnectSessionAccountDto,
                chainId = wcSession?.chainId
            ),
            sessionMeta = sessionEntity.wcSession
        )
    }

    override suspend fun getAllWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return walletConnectRepository.getWCSessionList().map { wcSessionDto ->
            val accounts = getConnectedAccountsOfWalletConnectSessionUseCase(wcSessionDto.id).map { sessionAccountDto ->
                sessionAccountDto.connectedAccountsAddress
            }
            val wcSession = getSessionById(wcSessionDto.id)
            walletConnectMapper.mapToSessionDetail(
                walletConnectSessionDto = wcSessionDto,
                namespaces = createWalletConnectSessionNamespaceUseCase.invoke(
                    accountAddresses = accounts,
                    chainId = wcSession?.chainId
                )
            )
        }
    }

    override suspend fun getSessionsByAccountAddress(accountAddress: String): List<WalletConnect.SessionDetail> {
        return getWalletConnectSessionsByAccountAddressUseCase(accountAddress).orEmpty()
    }

    override suspend fun getDisconnectedWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return getDisconnectedWalletConnectSessionsUseCase()
    }

    override suspend fun setAllSessionsDisconnected() {
        walletConnectRepository.setAllSessionsDisconnected()
    }

    override suspend fun disconnectFromAllSessions() {
        getAllWalletConnectSessions().forEach { sessionDetail ->
            identifierParser.withSessionId(sessionDetail.sessionIdentifier) { id ->
                getSessionById(id)?.disconnect()
            }
        }
    }

    override suspend fun connectToDisconnectedSessions() {
        getDisconnectedWalletConnectSessions().forEach { sessionDetail ->
            connect(sessionDetail.sessionIdentifier)
        }
    }

    override suspend fun initializeClient(application: Application) {
        deleteOldestSessionsIfCountExceed()
    }

    private fun connectToSession(sessionCacheData: WalletConnectV1SessionCachedData) {
        with(sessionCacheData) {
            addCallback(sessionCacheDataCallback)
            session.offer()
        }
        sessionCachedDataHandler.addNewCachedData(sessionCacheData)
    }

    private fun getSessionById(id: Long): WCSession? {
        return sessionCachedDataHandler.getSessionById(id)
    }

    private fun deleteSessionFromCacheById(id: Long) {
        sessionCachedDataHandler.deleteCachedData(id) { it.removeCallback() }
    }

    private suspend fun deleteSessionFromDbById(id: Long) {
        walletConnectRepository.deleteSessionById(id)
    }

    private suspend fun getSessionFromDBOrLogIfNotFound(
        sessionId: Long,
        funcName: String?
    ): WalletConnect.SessionDetail? {
        return getWalletConnectSession(sessionId).also { session ->
            if (session == null) logSessionNotFound(sessionId, funcName)
        }
    }

    private fun logSessionNotFound(sessionId: Long, funcName: String?) {
        val exception = WalletConnectSessionNotFoundException(
            sessionId = sessionId.toString(),
            className = javaClass.simpleName,
            functionName = funcName.orEmpty()
        )
        recordException(exception)
    }

    private suspend fun deleteOldestSessionsIfCountExceed() {
        val sessionCount = getWalletConnectV1SessionCountUseCase()
        val exceededAccountCount = sessionCount - MAX_LOCAL_SESSION_COUNT
        if (exceededAccountCount < 0) return
        getWalletConnectSessionsOrderedByCreationUseCase.invoke(exceededAccountCount).forEach {
            val sessionIdentifier = walletConnectMapper.mapToSessionIdentifier(it.id)
            killSession(sessionIdentifier)
        }
    }

    private fun processSessionRequest(
        requestId: Long,
        cachedData: WalletConnectV1SessionCachedData,
        call: Session.MethodCall.SessionRequest,
        chainId: Long?
    ) {
        coroutineScope.launchIO {
            if (sessionRequestIdValidationUseCase.isRequestAlreadyShown(requestId)) {
                return@launchIO
            }
            val sessionProposal = walletConnectMapper.mapToSessionProposal(
                sessionId = cachedData.sessionId,
                call = call,
                fallbackBrowserGroupResponse = cachedData.fallbackBrowserGroupResponse,
                namespaces = createWalletConnectProposalNamespaceUseCase(chainId)
            )
            sessionRequestIdValidationUseCase.setRequestShown(requestId)
            listener?.onSessionProposal(sessionProposal)
        }
    }

    private fun processTransactionRequest(
        cachedData: WalletConnectV1SessionCachedData,
        call: Session.MethodCall.Custom
    ) {
        coroutineScope.launchIO {
            val transactionRequestId = call.id
            if (transactionRequestIdValidationUseCase.isRequestAlreadyShown(transactionRequestId)) {
                return@launchIO
            }

            val sessionDetail = getSessionFromDBOrLogIfNotFound(
                sessionId = cachedData.sessionId,
                funcName = javaClass.enclosingMethod?.name
            ) ?: return@launchIO
            val request = walletConnectMapper.mapToSessionRequest(
                sessionDetail = sessionDetail,
                call = call,
                peerMeta = sessionDetail.peerMeta,
                chainId = null
            )
            transactionRequestIdValidationUseCase.setRequestShown(transactionRequestId)
            listener?.onSessionRequest(request)
        }
    }

    companion object {
        const val MAX_LOCAL_SESSION_COUNT: Int = 30
        const val CACHE_STORAGE_NAME = "session_store.json"
        const val INJECTION_NAME = "walletConnectClientV1InjectionName"
        val DEFAULT_CHAIN_IDENTIFIER_FOR_V1 = ChainIdentifier.MAINNET
    }
}
