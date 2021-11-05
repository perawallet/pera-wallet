/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NodeDao
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetStatus
import com.algorand.android.models.DeviceRegistrationRequest
import com.algorand.android.models.DeviceUpdateRequest
import com.algorand.android.models.Result
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import com.algorand.android.repository.AccountRepository
import com.algorand.android.repository.AssetRepository
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.AutoLockManager
import com.algorand.android.utils.BannerManager
import com.algorand.android.utils.BlockPollingManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.analytics.logRegisterEvent
import com.algorand.android.utils.findAllNodes
import com.algorand.android.utils.preference.getNotificationUserId
import com.algorand.android.utils.preference.setNotificationUserId
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@Suppress("LongParameterList")
class MainViewModel @ViewModelInject constructor(
    private val autoLockManager: AutoLockManager,
    private val sharedPref: SharedPreferences,
    private val nodeDao: NodeDao,
    private val indexerInterceptor: IndexerInterceptor,
    private val mobileHeaderInterceptor: MobileHeaderInterceptor,
    private val algodInterceptor: AlgodInterceptor,
    private val accountManager: AccountManager,
    private val notificationRepository: NotificationRepository,
    private val accountRepository: AccountRepository,
    private val assetRepository: AssetRepository,
    private val transactionRepository: TransactionsRepository,
    private val accountCacheManager: AccountCacheManager,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val bannerManager: BannerManager
) : BaseViewModel() {

    private val blockChainManager = BlockPollingManager(viewModelScope, transactionRepository)

    val addAssetResultLiveData = MutableLiveData<Event<Resource<Unit>>>()

    // TODO I'll change after checking usage of flow in activity.
    val accountBalanceSyncStatus = accountCacheManager.getCacheStatusFlow().asLiveData()
    val blockConnectionStableFlow = blockChainManager.blockConnectionStableFlow
    val lastBlockNumberSharedFlow = blockChainManager.lastBlockNumberSharedFlow

    val autoLockLiveData
        get() = autoLockManager.autoLockLiveData

    private var sendTransactionJob: Job? = null
    var refreshBalanceJob: Job? = null
    var verifiedAssetJob: Job? = null
    var registerDeviceJob: Job? = null

    init {
        setAlgorandGovernanceBannerAsVisible()
        initializeAccountBalanceRefresher()
        initializeNodeInterceptor()
        registerDevice()
        getVerifiedAssets()
    }

    private fun setAlgorandGovernanceBannerAsVisible() {
        bannerManager.setBannerVisible()
    }

    private fun initializeAccountBalanceRefresher() {
        viewModelScope.launch {
            blockChainManager.lastBlockNumberSharedFlow.collectLatest { lastBlockNumber ->
                if (lastBlockNumber != null) {
                    refreshAccountBalances()
                }
            }
        }
    }

    private fun initializeNodeInterceptor() {
        viewModelScope.launch(Dispatchers.IO) {
            if (indexerInterceptor.currentActiveNode == null) {
                val lastActivatedNode = findAllNodes(sharedPref, nodeDao).find { it.isActive }
                lastActivatedNode?.activate(indexerInterceptor, mobileHeaderInterceptor, algodInterceptor)
            }
        }
    }

    fun registerDevice() {
        FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
            accountManager.setFirebaseToken(token, false)
            val accountsPublicKeys = accountManager.getAccounts().map { account -> account.address }
            registerDeviceJob?.cancel()
            registerDeviceJob = viewModelScope.launch(Dispatchers.IO) {
                sendRegisterDevice(token, accountsPublicKeys)
            }
        }
    }

    private suspend fun sendRegisterDevice(firebaseMessagingToken: String, accountPublicKeys: List<String>) {
        if (firebaseMessagingToken.isBlank()) {
            val exception = Exception("firebase messaging token is empty\naccounts: $accountPublicKeys")
            FirebaseCrashlytics.getInstance().recordException(exception)
        }

        with(sharedPref.getNotificationUserId()) {
            if (!this.isNullOrEmpty()) {
                updateDeviceRegistration(this, firebaseMessagingToken, accountPublicKeys)
            } else {
                registerDevice(firebaseMessagingToken, accountPublicKeys)
            }
        }
    }

    private suspend fun updateDeviceRegistration(
        notificationUserId: String,
        firebaseMessagingToken: String,
        accountPublicKeys: List<String>
    ) {
        notificationRepository.putRequestUpdateDevice(
            notificationUserId, DeviceUpdateRequest(notificationUserId, firebaseMessagingToken, accountPublicKeys)
        ).use(
            onSuccess = { deviceUpdateResponse ->
                if (deviceUpdateResponse.userId != null) {
                    sharedPref.setNotificationUserId(deviceUpdateResponse.userId)
                }
            },
            onFailed = {
                delay(REGISTER_DEVICE_FAIL_DELAY)
                updateDeviceRegistration(notificationUserId, firebaseMessagingToken, accountPublicKeys)
            }
        )
    }

    private suspend fun registerDevice(firebaseMessagingToken: String, accountPublicKeys: List<String>) {
        notificationRepository.postRequestRegisterDevice(
            DeviceRegistrationRequest(firebaseMessagingToken, accountPublicKeys)
        ).use(
            onSuccess = { deviceRegistrationResponse ->
                if (deviceRegistrationResponse.userId != null) {
                    sharedPref.setNotificationUserId(deviceRegistrationResponse.userId)
                }
            },
            onFailed = {
                delay(REGISTER_DEVICE_FAIL_DELAY)
                registerDevice(firebaseMessagingToken, accountPublicKeys)
            }
        )
    }

    fun resetBlockPolling() {
        refreshBalanceJob?.cancel()
        blockChainManager.start()
    }

    fun activateBlockPolling() {
        blockChainManager.start()
    }

    fun stopBlockPolling() {
        blockChainManager.stop()
    }

    fun refreshAccountBalances() {
        if (refreshBalanceJob?.isActive == true) {
            return
        }

        refreshBalanceJob = viewModelScope.launch(Dispatchers.IO) {
            verifiedAssetJob?.join()

            accountManager.getAccounts().forEach {
                accountRepository.getAuthAccountInformation(it)
            }
        }
    }

    fun getVerifiedAssets() {
        verifiedAssetJob?.cancel()
        verifiedAssetJob = viewModelScope.launch(Dispatchers.IO) {
            when (val result = assetRepository.getVerifiedAssetList()) {
                is Result.Success -> {
                    accountCacheManager.setVerifiedAssetList(result.data.results)
                }
            }
        }
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        accountPublicKey: String
    ) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            when (transactionRepository.sendSignedTransaction(signedTransactionData)) {
                is Result.Success -> {
                    accountCacheManager.addAssetToAccount(accountPublicKey, assetInformation.apply {
                        assetStatus = AssetStatus.PENDING_FOR_ADDITION
                    })
                    addAssetResultLiveData.postValue(Event(Resource.Success(Unit)))
                }
            }
        }
    }

    fun addAccount(tempAccount: Account?, creationType: CreationType?): Boolean {
        if (tempAccount != null) {
            if (tempAccount.isRegistrationCompleted()) {
                firebaseAnalytics.logRegisterEvent(creationType)
                accountManager.addNewAccount(tempAccount)
                if (accountManager.getAccounts().size == 1) {
                    activateBlockPolling()
                }
                return true
            }
        }
        return false
    }

    fun setupAutoLockManager(lifecycle: Lifecycle) {
        autoLockManager.registerAppLifecycle(lifecycle)
    }

    companion object {
        private const val REGISTER_DEVICE_FAIL_DELAY = 1500L
    }
}
