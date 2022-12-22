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

package com.algorand.android.utils.walletconnect

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.algorand.android.R
import com.algorand.android.mapper.WalletConnectMapper
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.models.WalletConnectTransactionErrorResponse
import com.algorand.android.modules.walletconnect.domain.DeleteWalletConnectAccountBySessionUseCase
import com.algorand.android.modules.walletconnect.domain.GetWalletConnectSessionsByAccountAddressUseCase
import com.algorand.android.modules.walletconnect.domain.GetWalletConnectSessionsWithAccountsUseCase
import com.algorand.android.repository.WalletConnectRepository
import com.algorand.android.usecase.AccountCacheStatusUseCase
import com.algorand.android.usecase.GetActiveNodeChainIdUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.Resource.Error.Annotated
import com.algorand.android.utils.coremanager.ApplicationStatusObserver
import com.algorand.android.utils.exception.InvalidWalletConnectUrlException
import com.algorand.android.utils.exception.WalletConnectException
import com.algorand.android.utils.recordException
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Error
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Success
import java.io.EOFException
import java.net.ConnectException
import java.net.ProtocolException
import java.net.SocketException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import java.util.concurrent.TimeoutException
import javax.inject.Inject
import javax.inject.Named
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.filter
import kotlinx.coroutines.launch
import org.walletconnect.Session

@Singleton
@SuppressWarnings("LongParameterList", "TooManyFunctions")
class WalletConnectManager @Inject constructor(
    accountCacheStatusUseCase: AccountCacheStatusUseCase,
    @Named("wcWalletClient") private val walletConnectClient: WalletConnectClient,
    private val walletConnectRepository: WalletConnectRepository,
    private val walletConnectMapper: WalletConnectMapper,
    private val walletConnectCustomTransactionHandler: WalletConnectCustomTransactionHandler,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val eventLogger: WalletConnectEventLogger,
    private val getActiveNodeChainIdUseCase: GetActiveNodeChainIdUseCase,
    private val getWalletConnectSessionsByAccountAddressUseCase: GetWalletConnectSessionsByAccountAddressUseCase,
    private val getAllWalletConnectSessionWithAccountAddressesUseCase: GetWalletConnectSessionsWithAccountsUseCase,
    private val deleteWalletConnectAccountBySessionUseCase: DeleteWalletConnectAccountBySessionUseCase,
    private val applicationStatusObserver: ApplicationStatusObserver
) : DefaultLifecycleObserver {

    val sessionResultFlow: SharedFlow<Event<Resource<WalletConnectSession>>>
        get() = _sessionResultFlow
    private val _sessionResultFlow = MutableSharedFlow<Event<Resource<WalletConnectSession>>>()

    val requestLiveData: LiveData<Event<Resource<WalletConnectTransaction>>?>
        get() = _requestLiveData
    private val _requestLiveData = MutableLiveData<Event<Resource<WalletConnectTransaction>>?>()

    val requestResultLiveData: LiveData<Event<Resource<AnnotatedString>>>
        get() = _requestResultLiveData
    private val _requestResultLiveData = MutableLiveData<Event<Resource<AnnotatedString>>>()

    private val _invalidTransactionCauseLiveData = MutableLiveData<Event<Resource.Error.Local>>()
    val invalidTransactionCauseLiveData: LiveData<Event<Resource.Error.Local>> = _invalidTransactionCauseLiveData

    val localSessionsFlow: Flow<List<WalletConnectSession>>
        get() = getAllWalletConnectSessionWithAccountAddressesUseCase.invoke()

    val transaction: WalletConnectTransaction?
        get() = (requestLiveData.value?.peek() as? Resource.Success)?.data

    var onSessionTimedOut: (() -> Unit)? = null

    private var coroutineScope: CoroutineScope? = null

    private val accountCacheStatusFlow = accountCacheStatusUseCase.getAccountCacheStatusFlow()
    private val sessionConnectionTimer by lazy { WalletConnectSessionTimer(onSessionTimedOut) }

    // TODO Find better solution for multiple transaction request
    private var requestHandlingJob: Job? = null
    private var latestSessionIdIsBeingHandled: Long? = null
    private var latestRequestIdIsBeingHandled: Long? = null
    private var latestTransactionRequestId: Long? = null
    private var sessionEvent: Event<WalletConnectSession>? = null
    private var latestActiveChainId: Long? = null

    private val walletConnectClientListener = object : WalletConnectClientListener {
        override fun onSessionRequest(sessionId: Long, requestId: Long, session: WalletConnectSession, chainId: Long?) {
            stopSessionConnectionTimer()
            latestActiveChainId = chainId
            sessionEvent = Event(session)
            handleSessionRequest()
        }

        override fun onSessionUpdate(sessionId: Long, accounts: List<String>?, chainId: Long?) {
            latestActiveChainId = chainId
            updateSession(sessionId, accounts)
        }

        override fun onCustomRequest(sessionId: Long, requestId: Long, payloadList: List<*>) {
            handleCustomTransactionRequest(sessionId, requestId, payloadList)
        }

        override fun onFailure(sessionId: Long, error: Session.Status.Error) {
            onSessionFailed(sessionId, error)
        }

        override fun onDisconnected(sessionId: Long) {
            coroutineScope?.launch(Dispatchers.IO) {
                walletConnectRepository.setSessionDisconnected(sessionId)
            }
        }

        override fun onSessionKilled(sessionId: Long) {
            coroutineScope?.launch(Dispatchers.IO) {
                walletConnectRepository.deleteSessionById(sessionId)
            }
        }

        override fun onSessionApproved(sessionId: Long, session: WalletConnectSession) {
            coroutineScope?.launch(Dispatchers.IO) {
                insertWCSSession(session)
                walletConnectClient.clearSessionRetryCount(sessionId)
                subscribeWalletConnectSession(session)
            }
        }

        override fun onConnected(sessionId: Long, session: WalletConnectSession?) {
            coroutineScope?.launch(Dispatchers.IO) {
                _sessionResultFlow.emit(Event(Resource.OnLoadingFinished))
                if (session != null) {
                    val sessionEntity = walletConnectMapper.createWCSessionEntity(session)
                    walletConnectRepository.setConnectedSession(sessionEntity)
                    walletConnectClient.clearSessionRetryCount(sessionId)
                    subscribeWalletConnectSession(session)
                }
            }
        }
    }

    init {
        walletConnectClient.setListener(walletConnectClientListener)
    }

    fun connectToNewSession(url: String) {
        startSessionConnectionTimer()
        walletConnectClient.connect(url)
    }

    fun connectToExistingSession(session: WalletConnectSession) {
        with(walletConnectClient) {
            connect(
                sessionId = session.id,
                sessionMeta = session.sessionMeta,
                fallbackBrowserGroupResponse = session.fallbackBrowserGroupResponse
            )
        }
    }

    fun approveSession(session: WalletConnectSession, accountAddresses: List<String>) {
        walletConnectClient.approveSession(session.id, accountAddresses, latestActiveChainId)
        eventLogger.logSessionConfirmation(session, accountAddresses)
    }

    fun updateSession(sessionId: Long, accounts: List<String>?) {
        walletConnectClient.updateSession(sessionId, accounts, latestActiveChainId)
    }

    fun rejectSession(session: WalletConnectSession) {
        walletConnectClient.rejectSession(session.id)
        eventLogger.logSessionRejection(session)
    }

    fun killSession(session: WalletConnectSession) {
        walletConnectClient.killSession(session.id)
        eventLogger.logSessionDisconnection(session)
    }

    fun getWalletConnectSession(sessionId: Long): WalletConnectSession? {
        return walletConnectClient.getWalletConnectSession(sessionId)
    }

    fun setListener(listener: WalletConnectClientListener) {
        walletConnectClient.setListener(listener)
    }

    fun rejectRequest(sessionId: Long, requestId: Long?, errorResponse: WalletConnectTransactionErrorResponse) {
        if (requestId == null) return
        _requestResultLiveData.postValue(Event(Resource.Error.Local(errorResponse.message)))
        transaction?.run { eventLogger.logTransactionRequestRejection(this) }
        walletConnectClient.rejectRequest(sessionId, requestId, errorResponse)
        _requestLiveData.postValue(null)
    }

    fun processWalletConnectSignResult(walletConnectSignResult: WalletConnectSignResult) {
        with(walletConnectSignResult) {
            if (this is WalletConnectSignResult.Success) {
                walletConnectClient.approveRequest(sessionId, requestId, signedTransaction)
                transaction?.run { eventLogger.logTransactionRequestConfirmation(this) }
                _requestResultLiveData.postValue(
                    Event(Resource.Success(AnnotatedString(R.string.transaction_succesfully_confirmed)))
                )
                _requestLiveData.postValue(null)
            } else {
                _requestResultLiveData.postValue(Event(Annotated(AnnotatedString(R.string.an_error_occured))))
                val exception = Exception("Wallet connect sign result is not Success: $walletConnectSignResult")
                recordException(exception)
            }
        }
    }

    private fun handleSessionRequest() {
        coroutineScope?.launch(Dispatchers.IO) {
            accountCacheStatusFlow.filter { it == AccountCacheStatus.DONE }.distinctUntilChanged().collectLatest {
                sessionEvent?.consume()?.run {
                    checkIfRequestedSessionIdMatchWithActiveNode(
                        cachedSession = this,
                        onFailed = { errorResource -> _sessionResultFlow.emit(Event(errorResource)) },
                        onMatched = { cachedSessionResource -> _sessionResultFlow.emit(Event(cachedSessionResource)) }
                    )
                }
            }
        }
    }

    private suspend fun checkIfRequestedSessionIdMatchWithActiveNode(
        cachedSession: WalletConnectSession,
        onMatched: suspend (Resource.Success<WalletConnectSession>) -> Unit,
        onFailed: suspend (Resource.Error) -> Unit
    ) {
        val activeNodeChainId = getActiveNodeChainIdUseCase.getActiveNodeChainId()
        val safeChainId = latestActiveChainId ?: DEFAULT_CHAIN_ID
        if (activeNodeChainId == safeChainId || DEFAULT_CHAIN_ID == safeChainId) {
            onMatched.invoke(Resource.Success(cachedSession))
        } else {
            val annotatedString = AnnotatedString(stringResId = R.string.signing_error_network_mismatch)
            onFailed.invoke(Annotated(annotatedString))
        }
    }

    fun killAllSessions() {
        coroutineScope?.launch(Dispatchers.IO) {
            killAllSessions(walletConnectRepository.getWCSessionList())
        }
    }

    fun killAllSessionsByPublicKey(publicKey: String) {
        coroutineScope?.launch(Dispatchers.IO) {
            getWalletConnectSessionsByAccountAddressUseCase(publicKey)?.forEach { session ->
                if (session.connectedAccountsAddresses.singleOrNull() == publicKey) {
                    killSession(session)
                } else {
                    updateAccountsOfSession(
                        sessionId = session.id,
                        removedAccountAddress = publicKey,
                        sessionAccountAddresses = session.connectedAccountsAddresses
                    )
                }
            }
        }
    }

    private suspend fun updateAccountsOfSession(
        sessionId: Long,
        removedAccountAddress: String,
        sessionAccountAddresses: List<String>
    ) {
        val newSessionAccountAddresses = sessionAccountAddresses.toMutableList().apply {
            val deletedAccountIndex = indexOf(removedAccountAddress)
            removeAt(deletedAccountIndex)
        }
        deleteWalletConnectAccountBySessionUseCase(sessionId, removedAccountAddress)
        updateSession(sessionId, newSessionAccountAddresses)
    }

    private fun killAllSessions(wcSessionEntities: List<WalletConnectSessionEntity>) {
        wcSessionEntities.map { walletConnectMapper.createWalletConnectSession(it) }.forEach {
            killSession(it)
        }
    }

    private suspend fun insertWCSSession(wcSessionRequest: WalletConnectSession, isConnected: Boolean = true) {
        val wcSessionEntity = walletConnectMapper.createWCSessionEntity(wcSessionRequest)
            .copy(isConnected = isConnected)
        val wcSessionAccountList = walletConnectMapper.createWalletConnectSessionAccountList(wcSessionRequest)
        walletConnectRepository.insertConnectedWalletConnectSession(
            wcSessionEntity = wcSessionEntity,
            wcSessionAccountList = wcSessionAccountList
        )
    }

    private suspend fun subscribeWalletConnectSession(
        wcSessionRequest: WalletConnectSession,
        isConnected: Boolean = true
    ) {
        val wcSessionEntity = walletConnectMapper.createWCSessionEntity(wcSessionRequest)
            .copy(isConnected = isConnected)
        walletConnectRepository.subscribeWalletConnectSession(wcSessionEntity)
    }

    private fun connectToDisconnectedSessions() {
        coroutineScope?.launch(Dispatchers.IO) {
            walletConnectRepository.getAllDisconnectedSessions().map {
                walletConnectMapper.createWalletConnectSession(it)
            }.forEach { session ->
                connectToExistingSession(session)
            }
        }
    }

    private fun handleCustomTransactionRequest(sessionId: Long, requestId: Long, payloadList: List<*>) {
        if (requestHandlingJob?.isActive == true) {
            requestHandlingJob?.cancel()
            rejectLatestTransaction(latestRequestIdIsBeingHandled, latestSessionIdIsBeingHandled)
        } else if (!isLatestRequestHandled()) {
            rejectLatestTransaction(transaction?.requestId, transaction?.session?.id)
        }
        latestSessionIdIsBeingHandled = sessionId
        latestRequestIdIsBeingHandled = requestId
        requestHandlingJob = coroutineScope?.launch(Dispatchers.IO) {
            accountCacheStatusFlow.filter { it == AccountCacheStatus.DONE }.distinctUntilChanged().collectLatest {
                if (latestTransactionRequestId != requestId) {
                    latestTransactionRequestId = requestId
                    val session = walletConnectClient.getWalletConnectSession(sessionId) ?: return@collectLatest
                    walletConnectCustomTransactionHandler.handleCustomTransaction(
                        sessionId = sessionId,
                        requestId = requestId,
                        session = session,
                        payloadList = payloadList,
                        onResult = ::onCustomTransactionParsed
                    )
                }
            }
        }
    }

    private fun onCustomTransactionParsed(result: WalletConnectTransactionResult) {
        when (result) {
            is Success -> _requestLiveData.postValue(Event(Resource.Success(result.walletConnectTransaction)))
            is Error -> {
                walletConnectClient.rejectRequest(result.sessionId, result.requestId, result.errorResponse)
                _invalidTransactionCauseLiveData.postValue(Event(Resource.Error.Local(result.errorResponse.message)))
            }
        }
    }

    private fun isLatestRequestHandled(): Boolean {
        return (_requestLiveData.value as? Event<*>) == null
    }

    private fun rejectLatestTransaction(requestId: Long?, sessionId: Long?) {
        val rejectReason = errorProvider.rejected.pendingTransaction
        walletConnectClient.rejectRequest(sessionId ?: return, requestId ?: return, rejectReason)
    }

    private fun onSessionFailed(sessionId: Long, error: Session.Status.Error) {
        coroutineScope?.launch(Dispatchers.IO) {
            when (error.throwable.cause ?: error.throwable) {
                is ProtocolException -> {
                    _sessionResultFlow.emit(Event(Annotated(AnnotatedString(R.string.wallet_connect_is_not_reachable))))
                }
                is InvalidWalletConnectUrlException -> {
                    // TODO Add invalid url message here
                    _sessionResultFlow.emit(Event(Resource.OnLoadingFinished))
                }
                is EOFException -> {
                    // TODO: According to this issue, this is a [OkHttp] related issue.
                    //  So, I applied the recommended solution [https://github.com/square/okhttp/issues/7381] here.
                    delay(RECONNECTION_DELAY)
                    reconnectToDisconnectedSession(sessionId)
                }
                is ConnectException,
                is UnknownHostException,
                is SocketTimeoutException,
                is TimeoutException,
                is SocketException -> {
                    addSessionAndDeleteIfNeed(sessionId)
                }
                else -> {
                    recordException(WalletConnectException(throwable = error.throwable.cause ?: error.throwable))
                }
            }
        }
    }

    private suspend fun reconnectToDisconnectedSession(sessionId: Long) {
        val sessionEntity = walletConnectRepository.getSessionById(sessionId) ?: return
        increaseSessionRetryCount(sessionId)
        val disconnectedSessionMeta = sessionEntity.wcSession
        walletConnectClient.connect(
            sessionId = sessionId,
            sessionMeta = disconnectedSessionMeta,
            fallbackBrowserGroupResponse = sessionEntity.fallbackBrowserGroupResponse
        )
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
    private suspend fun addSessionAndDeleteIfNeed(sessionId: Long) {
        if (applicationStatusObserver.isAppOnBackground) return
        if (isSessionRetryCountExceeded(sessionId)) {
            val sessionEntity = walletConnectRepository.getSessionById(sessionId) ?: return
            killSession(walletConnectMapper.createWalletConnectSession(sessionEntity))
        } else {
            delay(RE_CONNECT_SESSION_TIME_INTERVAL)
            reconnectToDisconnectedSession(sessionId)
        }
    }

    private fun isSessionRetryCountExceeded(sessionId: Long): Boolean {
        val currentSessionRetryCount = walletConnectClient.getSessionRetryCount(sessionId)
        return currentSessionRetryCount > SESSION_RECONNECT_MAX_RETRY_COUNT
    }

    private fun increaseSessionRetryCount(sessionId: Long) {
        val increasedRetryCount = walletConnectClient.getSessionRetryCount(sessionId).inc()
        walletConnectClient.setSessionRetryCount(sessionId, increasedRetryCount)
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        coroutineScope = CoroutineScope(Job() + Dispatchers.Main).apply {
            launch(Dispatchers.IO) {
                walletConnectRepository.setAllSessionsDisconnected()
            }
        }
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        coroutineScope?.launch(Dispatchers.IO) {
            connectToDisconnectedSessions()
        }
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        coroutineScope?.cancel()
    }

    companion object {
        private const val RECONNECTION_DELAY = 100L
        private const val SESSION_RECONNECT_MAX_RETRY_COUNT = 20
        private const val RE_CONNECT_SESSION_TIME_INTERVAL = 3_000L
    }
}
