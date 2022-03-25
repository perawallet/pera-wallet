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

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.OnLifecycleEvent
import com.algorand.android.R
import com.algorand.android.mapper.WalletConnectMapper
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.models.WalletConnectTransactionErrorResponse
import com.algorand.android.repository.WalletConnectRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.Resource.Error.Annotated
import com.algorand.android.utils.exception.InvalidWalletConnectUrlException
import com.algorand.android.utils.recordException
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Error
import com.algorand.android.utils.walletconnect.WalletConnectTransactionResult.Success
import java.io.EOFException
import java.net.ProtocolException
import javax.inject.Inject
import javax.inject.Named
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import org.walletconnect.Session

@Singleton
class WalletConnectManager @Inject constructor(
    @Named("wcWalletClient") private val walletConnectClient: WalletConnectClient,
    private val walletConnectRepository: WalletConnectRepository,
    private val walletConnectMapper: WalletConnectMapper,
    private val walletConnectCustomTransactionHandler: WalletConnectCustomTransactionHandler,
    private val errorProvider: WalletConnectTransactionErrorProvider,
    private val eventLogger: WalletConnectEventLogger,
    private val accountCacheManager: AccountCacheManager
) : LifecycleObserver {

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
        get() = walletConnectRepository.getAllWCSession().map { entityList ->
            entityList.map { entity -> walletConnectMapper.createWalletConnectSession(entity) }
        }

    val transaction: WalletConnectTransaction?
        get() = (requestLiveData.value?.peek() as? Resource.Success)?.data

    var onSessionTimedOut: (() -> Unit)? = null

    private var coroutineScope: CoroutineScope? = null

    private val accountCacheStatusFlow = accountCacheManager.getCacheStatusFlow()
    private val sessionConnectionTimer by lazy { WalletConnectSessionTimer(onSessionTimedOut) }

    // TODO Find better solution for multiple transaction request
    private var requestHandlingJob: Job? = null
    private var latestSessionIdIsBeingHandled: Long? = null
    private var latestRequestIdIsBeingHandled: Long? = null
    private var latestTransactionRequestId: Long? = null
    private var sessionEvent: Event<WalletConnectSession>? = null

    private val walletConnectClientListener = object : WalletConnectClientListener {
        override fun onSessionRequest(sessionId: Long, requestId: Long, session: WalletConnectSession) {
            stopSessionConnectionTimer()
            sessionEvent = Event(session)
            handleSessionRequest()
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
            }
        }

        override fun onConnected(sessionId: Long, session: WalletConnectSession?) {
            coroutineScope?.launch(Dispatchers.IO) {
                _sessionResultFlow.emit(Event(Resource.OnLoadingFinished))
                if (session != null) {
                    val sessionEntity = walletConnectMapper.createWCSessionEntity(session)
                    walletConnectRepository.setConnectedSession(sessionEntity)
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
            connect(session.id, session.sessionMeta)
        }
    }

    fun approveSession(session: WalletConnectSession, address: String) {
        walletConnectClient.approveSession(session.id, address)
        eventLogger.logSessionConfirmation(session, address)
    }

    fun rejectSession(session: WalletConnectSession) {
        walletConnectClient.rejectSession(session.id)
        eventLogger.logSessionRejection(session)
    }

    fun killSession(session: WalletConnectSession) {
        walletConnectClient.killSession(session.id)
        eventLogger.logSessionDisconnection(session)
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
            accountCacheStatusFlow.collectLatest {
                if (it == AccountCacheStatus.DONE && sessionEvent?.consumed == false) {
                    val cachedSession = sessionEvent?.consume() ?: return@collectLatest
                    _sessionResultFlow.emit(Event(Resource.Success(cachedSession)))
                }
            }
        }
    }

    fun killAllSessions() {
        coroutineScope?.launch(Dispatchers.IO) {
            killAllSessions(walletConnectRepository.getWCSessionList())
        }
    }

    fun killAllSessionsByPublicKey(publicKey: String) {
        coroutineScope?.launch(Dispatchers.IO) {
            killAllSessions(walletConnectRepository.getWCSessionListByPublicKey(publicKey))
        }
    }

    private fun killAllSessions(wcSessionEntities: List<WalletConnectSessionEntity>) {
        wcSessionEntities.map { walletConnectMapper.createWalletConnectSession(it) }.forEach {
            killSession(it)
        }
    }

    private suspend fun insertWCSSession(wcSessionRequest: WalletConnectSession, isConnected: Boolean = true) {
        val wcSessionEntity = walletConnectMapper.createWCSessionEntity(wcSessionRequest)
            .copy(isConnected = isConnected)
        val wcSessionHistoryEntity = walletConnectMapper.createWCSessionHistoryEntity(wcSessionRequest)
        walletConnectRepository.insertConnectedWalletConnectSession(wcSessionEntity, wcSessionHistoryEntity)
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
            accountCacheStatusFlow.collectLatest {
                if (it == AccountCacheStatus.DONE && latestTransactionRequestId != requestId) {
                    latestTransactionRequestId = requestId
                    val session = walletConnectClient.getWalletConnectSession(sessionId) ?: return@collectLatest
                    with(walletConnectCustomTransactionHandler) {
                        handleCustomTransaction(sessionId, requestId, session, payloadList, ::onCustomTransactionParsed)
                    }
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
                is EOFException -> reconnectToDisconnectedSession(sessionId)
            }
        }
    }

    private suspend fun reconnectToDisconnectedSession(sessionId: Long) {
        val disconnectedSessionMeta = walletConnectRepository.getSessionById(sessionId)?.wcSession ?: return
        walletConnectClient.connect(sessionId, disconnectedSessionMeta)
    }

    private fun startSessionConnectionTimer() {
        sessionConnectionTimer.start()
    }

    private fun stopSessionConnectionTimer() {
        sessionConnectionTimer.cancel()
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
    private fun onCreate() {
        coroutineScope = CoroutineScope(Job() + Dispatchers.Main).apply {
            launch(Dispatchers.IO) {
                walletConnectRepository.setAllSessionsDisconnected()
            }
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
    private fun onResume() {
        coroutineScope?.launch(Dispatchers.IO) {
            connectToDisconnectedSessions()
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    private fun onDestroy() {
        coroutineScope?.cancel()
    }
}
