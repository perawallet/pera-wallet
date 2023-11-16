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

package com.algorand.android.modules.walletconnect.domain

import android.app.Application
import android.util.Base64
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.algorand.android.R
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectRequest
import com.algorand.android.models.WalletConnectRequest.WalletConnectArbitraryDataRequest
import com.algorand.android.models.WalletConnectRequest.WalletConnectTransaction
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectSessionTimer
import com.algorand.android.modules.walletconnect.domain.decider.WalletConnectMethodDecider
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.RequestIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.SessionIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectError
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectMethod
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.ui.mapper.WalletConnectPreviewMapper
import com.algorand.android.modules.walletconnect.ui.mapper.WalletConnectSessionIdentifierMapper
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.usecase.AccountCacheStatusUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.Resource.Error.Annotated
import com.algorand.android.utils.convertSecToMills
import com.algorand.android.utils.coremanager.ApplicationStatusObserver
import com.algorand.android.utils.exception.InvalidWalletConnectUrlException
import com.algorand.android.utils.launchIO
import com.algorand.android.utils.recordException
import com.algorand.android.utils.walletconnect.WalletConnectCustomArbitraryDataHandler
import com.algorand.android.utils.walletconnect.WalletConnectCustomTransactionHandler
import com.algorand.android.utils.walletconnect.WalletConnectEventLogger
import com.algorand.android.utils.walletconnect.WalletConnectRequestResult
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.math.pow
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter

@Singleton
@SuppressWarnings("TooManyFunctions", "LongParameterList")
class WalletConnectManager @Inject constructor(
    accountCacheStatusUseCase: AccountCacheStatusUseCase,
    private val walletConnectCustomTransactionHandler: WalletConnectCustomTransactionHandler,
    private val walletConnectCustomArbitraryDataHandler: WalletConnectCustomArbitraryDataHandler,
    private val errorProvider: WalletConnectErrorProvider,
    private val eventLogger: WalletConnectEventLogger,
    private val getActiveNodeChainIdUseCase: GetActiveNodeChainIdUseCase,
    private val applicationStatusObserver: ApplicationStatusObserver,
    private val walletConnectClientManager: WalletConnectClientManager,
    private val walletConnectPreviewMapper: WalletConnectPreviewMapper,
    private val walletConnectSessionIdentifierMapper: WalletConnectSessionIdentifierMapper,
    private val walletConnectMethodDecider: WalletConnectMethodDecider
) : DefaultLifecycleObserver {

    val sessionResultFlow: SharedFlow<Event<Resource<WalletConnectSessionProposal>>>
        get() = _sessionResultFlow
    private val _sessionResultFlow = MutableSharedFlow<Event<Resource<WalletConnectSessionProposal>>>()

    val sessionSettleFlow: SharedFlow<Event<WalletConnectSessionIdentifier>>
        get() = _sessionSettleFlow
    private val _sessionSettleFlow = MutableSharedFlow<Event<WalletConnectSessionIdentifier>>()

    val walletConnectRequestLiveData: LiveData<Event<Resource<WalletConnectRequest>>?>
        get() = _walletConnectRequestLiveData
    private val _walletConnectRequestLiveData = MutableLiveData<Event<Resource<WalletConnectRequest>>?>()

    val requestResultLiveData: LiveData<Event<Resource<AnnotatedString>>>
        get() = _requestResultLiveData
    private val _requestResultLiveData = MutableLiveData<Event<Resource<AnnotatedString>>>()

    private val _invalidTransactionCauseLiveData = MutableLiveData<Event<Resource.Error.Local>>()
    val invalidTransactionCauseLiveData: LiveData<Event<Resource.Error.Local>> = _invalidTransactionCauseLiveData

    val localSessionsFlow: Flow<List<WalletConnect.SessionDetail>>
        get() = _localSessionsFlow
    private val _localSessionsFlow: MutableStateFlow<List<WalletConnect.SessionDetail>> = MutableStateFlow(emptyList())

    val wcRequest: WalletConnectRequest?
        get() = (walletConnectRequestLiveData.value?.peek() as? Resource.Success)?.data

    var onSessionTimedOut: (() -> Unit)? = null

    private var coroutineScope: CoroutineScope? = null

    private val accountCacheStatusFlow = accountCacheStatusUseCase.getAccountCacheStatusFlow()
    private val sessionConnectionTimer by lazy { WalletConnectSessionTimer(onSessionTimedOut) }

    // TODO Find better solution for multiple transaction request
    private var sessionRequestHandlingJob: Job? = null
    private var latestSessionIdentifierIsBeingHandled: SessionIdentifier? = null
    private var latestRequestIdentifierIsBeingHandled: RequestIdentifier? = null
    private var latestTransactionRequestIdentifier: RequestIdentifier? = null
    private var sessionEvent: Event<WalletConnectSessionProposal>? = null

    private val walletConnectClientListener = object : WalletConnectClientManagerListener {

        override fun onInvalidSessionUrl(url: String) {
            coroutineScope?.launchIO {
                _sessionResultFlow.emit(Event(Annotated(AnnotatedString(R.string.invalid_url))))
            }
        }

        override fun onSessionProposal(proposal: WalletConnect.Session.Proposal) {
            stopSessionConnectionTimer()
            val sessionProposal = walletConnectPreviewMapper.mapToWalletConnectSessionProposal(proposal)
            sessionEvent = Event(sessionProposal)
            handleSessionProposal()
        }

        override fun onSessionUpdate(update: WalletConnect.Session.Update) {
            if (update is WalletConnect.Session.Update.Success) {
                coroutineScope?.launchIO { updateLocalSessionsFlow() }
            }
        }

        override fun onSessionDelete(delete: WalletConnect.Session.Delete) {
            coroutineScope?.launchIO {
                updateLocalSessionsFlow()
            }
        }

        override fun onSessionSettle(settle: WalletConnect.Session.Settle) {
            if (settle is WalletConnect.Session.Settle.Result) {
                coroutineScope?.launchIO {
                    val sessionIdentifier = walletConnectSessionIdentifierMapper.mapToSessionIdentifier(
                        settle.session.sessionIdentifier.getIdentifier(),
                        settle.versionIdentifier
                    )
                    _sessionSettleFlow.emit(Event(sessionIdentifier))
                    walletConnectClientManager.clearSessionRetryCount(settle.session.sessionIdentifier)
                    updateLocalSessionsFlow()
                }
            }
        }

        override fun onSessionError(error: WalletConnect.Session.Error) {
            onSessionFailed(error.sessionIdentifier, error.throwable)
        }

        override fun onSessionRequest(sessionRequest: WalletConnect.Model.SessionRequest) {
            coroutineScope?.launchIO {
                with(sessionRequest) {
                    if (request.params != null) {
                        handleSessionRequest(sessionIdentifier, request)
                    }
                }
            }
        }

        override fun onConnectionChanged(connectionState: WalletConnect.Model.ConnectionState) {
            coroutineScope?.launchIO {
                with(connectionState) {
                    if (isConnected) {
                        walletConnectClientManager.clearSessionRetryCount(session.sessionIdentifier)
                    }
                }
                updateLocalSessionsFlow()
            }
        }

        override fun onError(error: WalletConnect.Model.Error) {
            onSessionFailed(null, error.throwable)
        }
    }

    init {
        walletConnectClientManager.setListener(walletConnectClientListener)
    }

    fun connectToNewSession(url: String) {
        startSessionConnectionTimer()
        walletConnectClientManager.connect(url)
    }

    suspend fun connectToExistingSession(session: WalletConnect.SessionDetail) {
        walletConnectClientManager.connect(session.sessionIdentifier)
    }

    suspend fun approveSession(sessionProposal: WalletConnectSessionProposal, accountAddresses: List<String>) {
        val versionIdentifier = sessionProposal.proposalIdentifier.versionIdentifier
        val proposalNamespace = walletConnectPreviewMapper.mapToNamespaceProposal(
            sessionProposal.requiredNamespaces,
            versionIdentifier
        )
        walletConnectClientManager.approveSession(sessionProposal, proposalNamespace, accountAddresses)
        eventLogger.logSessionConfirmation(sessionProposal, accountAddresses)
    }

    private suspend fun updateSession(
        sessionIdentifier: SessionIdentifier,
        accounts: List<String>?,
        removedAccountAddress: String?
    ) {
        walletConnectClientManager.updateSession(
            sessionIdentifier = sessionIdentifier,
            accountList = accounts.orEmpty(),
            removedAccountAddress = removedAccountAddress
        )
    }

    suspend fun rejectSession(sessionProposal: WalletConnectSessionProposal) {
        walletConnectClientManager.rejectSession(sessionProposal, errorProvider.getUserRejectionError().message)
        eventLogger.logSessionRejection(sessionProposal)
    }

    suspend fun killSession(sessionIdentifier: WalletConnectSessionIdentifier) {
        val sessionDetail = getWalletConnectSession(sessionIdentifier) ?: return
        killSession(sessionDetail)
    }

    suspend fun killSession(session: WalletConnect.SessionDetail) {
        walletConnectClientManager.killSession(session.sessionIdentifier)
        eventLogger.logSessionDisconnection(session)
    }

    suspend fun getWalletConnectSession(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): WalletConnect.SessionDetail? {
        return walletConnectClientManager.getSessionDetail(sessionIdentifier)
    }

    suspend fun rejectRequest(
        sessionIdentifier: WalletConnectSessionIdentifier,
        requestId: Long,
        errorResponse: WalletConnectError
    ) {
        logWalletConnectRequestRejection()

        _requestResultLiveData.postValue(Event(Resource.Error.Local(errorResponse.message)))

        walletConnectClientManager.rejectRequest(
            sessionId = sessionIdentifier.sessionIdentifier,
            requestId = requestId,
            versionIdentifier = sessionIdentifier.versionIdentifier,
            errorResponse = errorResponse
        )
        _walletConnectRequestLiveData.postValue(null)
    }

    suspend fun processWalletConnectSignResult(walletConnectSignResult: WalletConnectSignResult) {
        with(walletConnectSignResult) {
            if (this is WalletConnectSignResult.Success) {
                walletConnectClientManager.approveRequest(
                    sessionIdentifier = sessionIdentifier,
                    requestId = requestId,
                    signedTransaction = signedTransaction.map { it?.let { Base64.encodeToString(it, Base64.DEFAULT) } }
                )
                logWalletConnectRequestConfirmation()
                _requestResultLiveData.postValue(
                    Event(Resource.Success(AnnotatedString(R.string.transaction_succesfully_confirmed)))
                )
                _walletConnectRequestLiveData.postValue(null)
            } else {
                _requestResultLiveData.postValue(Event(Annotated(AnnotatedString(R.string.an_error_occured))))
                val exception = Exception("Wallet connect sign result is not Success: $walletConnectSignResult")
                recordException(exception)
            }
        }
    }

    private fun logWalletConnectRequestRejection() {
        when (wcRequest) {
            is WalletConnectArbitraryDataRequest -> {
                eventLogger.logArbitraryDataRequestRejection(wcRequest as WalletConnectArbitraryDataRequest)
            }

            is WalletConnectTransaction -> {
                eventLogger.logTransactionRequestRejection(wcRequest as WalletConnectTransaction)
            }

            null -> {}
        }
    }

    private fun logWalletConnectRequestConfirmation() {
        when (wcRequest) {
            is WalletConnectArbitraryDataRequest -> {
                eventLogger.logArbitraryDataRequestConfirmation(wcRequest as WalletConnectArbitraryDataRequest)
            }

            is WalletConnectTransaction -> {
                wcRequest?.run { eventLogger.logTransactionRequestConfirmation(wcRequest as WalletConnectTransaction) }
            }

            null -> {}
        }
    }

    suspend fun getWalletConnectSessionsWithPairId(topic: String): List<WalletConnect.SessionDetail> {
        return walletConnectClientManager.getAllWalletConnectSessions().filter {
            it.topic == topic
        }
    }

    fun isValidWalletConnectUrl(url: String): Boolean {
        return walletConnectClientManager.isValidWalletConnectUrl(url)
    }

    suspend fun extendSessionExpirationDate(sessionIdentifier: WalletConnectSessionIdentifier): Result<String> {
        return walletConnectClientManager.extendSession(sessionIdentifier)
    }

    suspend fun isSessionExtendable(sessionIdentifier: WalletConnectSessionIdentifier): Boolean? {
        return walletConnectClientManager.isSessionExtendable(sessionIdentifier)
    }

    suspend fun hasSessionReachedMaxValidity(sessionIdentifier: WalletConnectSessionIdentifier): Boolean? {
        return walletConnectClientManager.hasSessionReachedMaxValidity(sessionIdentifier)
    }

    suspend fun getSessionExpirationDateExtendedTimeStampAsSec(
        sessionIdentifier: WalletConnectSessionIdentifier
    ): Long? {
        return walletConnectClientManager.getSessionExpirationDateExtendedTimeStampAsSec(sessionIdentifier)
    }

    suspend fun getSessionExpirationDateTimeStampAsSec(sessionIdentifier: SessionIdentifier): Long? {
        return walletConnectClientManager.getSessionExpirationDateTimeStampAsSec(sessionIdentifier)
    }

    suspend fun getSessionExpirationDateTimeStampAsSec(sessionIdentifier: WalletConnectSessionIdentifier): Long? {
        return walletConnectClientManager.getSessionExpirationDateTimeStampAsSec(sessionIdentifier)
    }

    suspend fun getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier: WalletConnectSessionIdentifier): Long? {
        return walletConnectClientManager.getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier)
    }

    suspend fun getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier: SessionIdentifier): Long? {
        return walletConnectClientManager.getMaxSessionExpirationDateTimeStampAsSec(sessionIdentifier)
    }

    suspend fun checkSessionStatus(sessionIdentifier: WalletConnectSessionIdentifier): Result<Unit> {
        return walletConnectClientManager.checkSessionStatus(sessionIdentifier)
    }

    private fun handleSessionProposal() {
        coroutineScope?.launchIO {
            accountCacheStatusFlow.filter { it == AccountCacheStatus.DONE }.distinctUntilChanged().collectLatest {
                sessionEvent?.consume()?.run {
                    checkIfRequestedSessionIdMatchWithActiveNode(
                        sessionProposal = this,
                        onFailed = { errorResource -> _sessionResultFlow.emit(Event(errorResource)) },
                        onMatched = { cachedSessionResource -> _sessionResultFlow.emit(Event(cachedSessionResource)) }
                    )
                }
            }
        }
    }

    private suspend fun checkIfRequestedSessionIdMatchWithActiveNode(
        sessionProposal: WalletConnectSessionProposal,
        onMatched: suspend (Resource.Success<WalletConnectSessionProposal>) -> Unit,
        onFailed: suspend (Resource.Error) -> Unit
    ) {
        val activeNodeChainId = getActiveNodeChainIdUseCase.getActiveNodeChainId()
        val algorandRequestedChainIds = sessionProposal.requiredNamespaces[WalletConnectBlockchain.ALGORAND]?.chains
        if (algorandRequestedChainIds?.contains(activeNodeChainId) == true) {
            onMatched.invoke(Resource.Success(sessionProposal))
        } else {
            val annotatedString = AnnotatedString(stringResId = R.string.signing_error_network_mismatch)
            onFailed.invoke(Annotated(annotatedString))
        }
    }

    fun killAllSessions() {
        coroutineScope?.launchIO {
            killAllSessions(walletConnectClientManager.getAllWalletConnectSessions())
            updateLocalSessionsFlow()
        }
    }

    fun killAllSessionsByPublicKey(accountAddress: String) {
        coroutineScope?.launchIO {
            walletConnectClientManager.getSessionsByAccountAddress(accountAddress).forEach { session ->
                val connectedAddress = session.namespaces.values.map { it.accounts }.flatten().map { it.accountAddress }
                if (connectedAddress.singleOrNull() == accountAddress) {
                    killSession(session)
                } else {
                    updateAccountsOfSession(session.sessionIdentifier, accountAddress, connectedAddress)
                }
            }
        }
    }

    private suspend fun updateAccountsOfSession(
        sessionIdentifier: SessionIdentifier,
        removedAccountAddress: String,
        sessionAccountAddresses: List<String>,
    ) {
        val newSessionAccountAddresses = sessionAccountAddresses.toMutableList().apply {
            val deletedAccountIndex = indexOf(removedAccountAddress)
            removeAt(deletedAccountIndex)
        }
        updateSession(sessionIdentifier, newSessionAccountAddresses, removedAccountAddress)
    }

    private suspend fun killAllSessions(wcSessionEntities: List<WalletConnect.SessionDetail>) {
        wcSessionEntities.forEach { killSession(it) }
        updateLocalSessionsFlow()
    }

    fun disconnectFromExistingSessions() {
        coroutineScope?.launchIO {
            walletConnectClientManager.disconnectFromAllSessions()
        }
    }

    fun connectToDisconnectedSessions() {
        coroutineScope?.launchIO {
            walletConnectClientManager.connectToDisconnectedSessions()
        }
    }

    suspend fun initializeClients(application: Application) {
        walletConnectClientManager.initializeClients(application)
        initializeCoroutineScope()
        connectToDisconnectedSessions()
    }

    private suspend fun handleSessionRequest(
        sessionIdentifier: SessionIdentifier,
        request: WalletConnect.Model.SessionRequest.JSONRPCRequest,
    ) {
        prepareSessionRequestHandler()

        val requestIdentifier = request.requestIdentifier
        val payloadList = request.params ?: return

        latestSessionIdentifierIsBeingHandled = sessionIdentifier
        latestRequestIdentifierIsBeingHandled = requestIdentifier

        sessionRequestHandlingJob = coroutineScope?.launchIO {

            accountCacheStatusFlow.filter { it == AccountCacheStatus.DONE }.distinctUntilChanged().collectLatest {
                if (latestTransactionRequestIdentifier != requestIdentifier) {
                    latestTransactionRequestIdentifier = requestIdentifier
                    val session = walletConnectClientManager.getSessionDetail(sessionIdentifier)
                    if (session != null) {
                        coroutineScope?.let { safeCoroutineScope ->
                            val method = getWCRequestMethod(request.method, session.versionIdentifier)
                            when (method) {
                                WalletConnectMethod.ALGO_SIGN_TXN, WalletConnectMethod.UNKNOWN -> {
                                    walletConnectCustomTransactionHandler.handleCustomTransaction(
                                        sessionIdentifier = sessionIdentifier,
                                        requestIdentifier = requestIdentifier,
                                        session = session,
                                        payloadList = payloadList,
                                        scope = safeCoroutineScope,
                                        onResult = ::onWalletConnectRequestParsed,
                                    )
                                }

                                WalletConnectMethod.ALGO_SIGN_DATA -> {
                                    walletConnectCustomArbitraryDataHandler.handleArbitraryData(
                                        sessionIdentifier = sessionIdentifier,
                                        requestIdentifier = requestIdentifier,
                                        session = session,
                                        payloadList = payloadList,
                                        onResult = ::onWalletConnectRequestParsed,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private fun getWCRequestMethod(
        method: String,
        versionIdentifier: WalletConnectVersionIdentifier
    ): WalletConnectMethod {
        return walletConnectMethodDecider.decideMethod(
            method,
            versionIdentifier
        )
    }

    private suspend fun prepareSessionRequestHandler() {
        if (sessionRequestHandlingJob?.isActive == true) {
            sessionRequestHandlingJob?.cancel()
            rejectLatestTransaction(latestSessionIdentifierIsBeingHandled, latestRequestIdentifierIsBeingHandled)
        } else if (!isLatestRequestHandled()) {
            wcRequest?.run {
                rejectLatestTransaction(session.sessionIdentifier.sessionIdentifier, requestId, versionIdentifier)
            }
        }
    }

    private suspend fun onWalletConnectRequestParsed(result: WalletConnectRequestResult) {
        when (result) {
            is WalletConnectRequestResult.Success -> {
                _walletConnectRequestLiveData.postValue(Event(Resource.Success(result.walletConnectRequest)))
            }

            is WalletConnectRequestResult.Error -> {
                with(result) {
                    walletConnectClientManager.rejectRequest(sessionIdentifier, requestIdentifier, errorResponse)
                    _invalidTransactionCauseLiveData.postValue(Event(Resource.Error.Local(errorResponse.message)))
                }
            }
        }.also { sessionRequestHandlingJob?.cancel() }
    }

    private fun isLatestRequestHandled(): Boolean {
        return (_walletConnectRequestLiveData.value as? Event<*>) == null
    }

    private suspend fun rejectLatestTransaction(
        sessionIdentifier: SessionIdentifier?,
        requestIdentifier: RequestIdentifier?
    ) {
        val rejectReason = errorProvider.getPendingTransactionError()
        if (sessionIdentifier != null && requestIdentifier != null) {
            walletConnectClientManager.rejectRequest(sessionIdentifier, requestIdentifier, rejectReason)
        }
    }

    private suspend fun rejectLatestTransaction(
        sessionId: String,
        requestId: Long?,
        versionIdentifier: WalletConnectVersionIdentifier?
    ) {
        val rejectReason = errorProvider.getPendingTransactionError()
        if (requestId != null && versionIdentifier != null) {
            walletConnectClientManager.rejectRequest(sessionId, requestId, versionIdentifier, rejectReason)
        }
    }

    private fun onSessionFailed(sessionIdentifier: SessionIdentifier?, throwable: Throwable) {
        coroutineScope?.launchIO {
            when (throwable.cause ?: throwable) {
                is InvalidWalletConnectUrlException -> {
                    _sessionResultFlow.emit(Event(Resource.OnLoadingFinished))
                }

                else -> {
                    reconnectToSessionAfterDelay(sessionIdentifier)
                }
            }
            updateLocalSessionsFlow()
        }
    }

    private suspend fun reconnectToDisconnectedSession(sessionIdentifier: SessionIdentifier) {
        increaseSessionRetryCount(sessionIdentifier)
        walletConnectClientManager.connect(sessionIdentifier)
    }

    private fun startSessionConnectionTimer() {
        sessionConnectionTimer.start()
    }

    private fun stopSessionConnectionTimer() {
        sessionConnectionTimer.cancel()
    }

    /**
     * The purpose of checking [isAppOnBackground] is that we shouldn't try to reconnect failed session again and again
     * while the app is in the background. It was causing session deletion in case of no internet connection. So, we are
     * trying to reconnect the user only while the app is in the foreground
     */
    private suspend fun reconnectToSessionAfterDelay(sessionIdentifier: SessionIdentifier?) {
        if (applicationStatusObserver.isAppOnBackground || sessionIdentifier == null) return
        val reconnectionDelay = calculateReconnectionDelay(sessionIdentifier)
        delay(reconnectionDelay)
        reconnectToDisconnectedSession(sessionIdentifier)
    }

    private suspend fun calculateReconnectionDelay(sessionIdentifier: SessionIdentifier): Long {
        val sessionRetryCount = walletConnectClientManager.getSessionRetryCount(sessionIdentifier)
            ?: FALLBACK_SESSION_RETRY_COUNT
        val retryIntervalAsSeconds = SESSION_RECONNECT_BASE_TIME_INTERVAL_AS_SEC.pow(sessionRetryCount)
        return convertSecToMills(retryIntervalAsSeconds.toLong())
    }

    private suspend fun increaseSessionRetryCount(sessionIdentifier: SessionIdentifier) {
        val sessionRetryCount = walletConnectClientManager.getSessionRetryCount(sessionIdentifier)
            ?: FALLBACK_SESSION_RETRY_COUNT
        val increasedRetryCount = sessionRetryCount.inc()
        walletConnectClientManager.setSessionRetryCount(sessionIdentifier, increasedRetryCount)
    }

    suspend fun updateLocalSessionsFlow() {
        _localSessionsFlow.value = walletConnectClientManager.getAllWalletConnectSessions()
    }

    private fun initializeCoroutineScope() {
        if (coroutineScope == null) coroutineScope = CoroutineScope(Job() + Dispatchers.Main)
    }

    // region Lifecycle Methods
    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        coroutineScope?.launchIO {
            walletConnectClientManager.setAllSessionsDisconnected()
        }
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        coroutineScope?.cancel()
    }
    // endregion

    companion object {
        private const val SESSION_RECONNECT_BASE_TIME_INTERVAL_AS_SEC = 3F
        private const val FALLBACK_SESSION_RETRY_COUNT = 3
    }
}
