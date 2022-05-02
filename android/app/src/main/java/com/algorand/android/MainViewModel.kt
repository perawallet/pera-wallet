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

package com.algorand.android

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NodeDao
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdMigrationUseCase
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.deviceregistration.domain.usecase.DeviceRegistrationUseCase
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.deviceregistration.domain.usecase.UpdatePushTokenUseCase
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Node
import com.algorand.android.models.Result
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AssetAdditionUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.AutoLockManager
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.analytics.logRegisterEvent
import com.algorand.android.utils.coremanager.BlockPollingManager
import com.algorand.android.utils.findAllNodes
import com.google.firebase.analytics.FirebaseAnalytics
import com.google.firebase.messaging.FirebaseMessaging
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collect
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
    private val transactionRepository: TransactionsRepository,
    private val accountCacheManager: AccountCacheManager,
    private val blockPollingManager: BlockPollingManager,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val bannersUseCase: BannersUseCase,
    private val assetAdditionUseCase: AssetAdditionUseCase,
    private val deviceRegistrationUseCase: DeviceRegistrationUseCase,
    private val deviceIdMigrationUseCase: DeviceIdMigrationUseCase,
    private val firebasePushTokenUseCase: FirebasePushTokenUseCase,
    private val updatePushTokenUseCase: UpdatePushTokenUseCase,
    private val deviceIdUseCase: DeviceIdUseCase
) : BaseViewModel() {

    val addAssetResultLiveData = MutableLiveData<Event<Resource<Unit>>>()

    // TODO I'll change after checking usage of flow in activity.
    val accountBalanceSyncStatus = accountCacheManager.getCacheStatusFlow().asLiveData()

    val autoLockLiveData
        get() = autoLockManager.autoLockLiveData

    fun checkLockState() {
        autoLockManager.checkLockState()
    }

    private var sendTransactionJob: Job? = null
    var refreshBalanceJob: Job? = null
    var registerDeviceJob: Job? = null

    init {
        initializeAccountCacheManager()
        initializeNodeInterceptor()
        observeFirebasePushToken()
        refreshFirebasePushToken(null)
    }

    private fun observeFirebasePushToken() {
        viewModelScope.launch {
            firebasePushTokenUseCase.getPushTokenCacheFlow().collect {
                if (it?.data.isNullOrBlank().not()) registerFirebasePushToken(it?.data.orEmpty())
            }
        }
    }

    private fun initializeNodeInterceptor() {
        viewModelScope.launch(Dispatchers.IO) {
            if (indexerInterceptor.currentActiveNode == null) {
                val lastActivatedNode = findAllNodes(sharedPref, nodeDao).find { it.isActive }
                lastActivatedNode?.activate(indexerInterceptor, mobileHeaderInterceptor, algodInterceptor)
            }
            migrateDeviceIdIfNeed()
        }
    }

    private fun registerFirebasePushToken(token: String) {
        registerDeviceJob?.cancel()
        registerDeviceJob = viewModelScope.launch(Dispatchers.IO) {
            deviceRegistrationUseCase.registerDevice(token).collect {
                if (it is DataResource.Success) bannersUseCase.cacheBanners(it.data)
            }
        }
    }

    fun refreshFirebasePushToken(previousNode: Node?) {
        if (previousNode != null) deletePreviousNodePushToken(previousNode)
        FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
            firebasePushTokenUseCase.setPushToken(token)
        }
    }

    private fun deletePreviousNodePushToken(previousNode: Node) {
        viewModelScope.launch(Dispatchers.IO) {
            val deviceId = deviceIdUseCase.getNodeDeviceId(previousNode) ?: run {
                return@launch
            }
            updatePushTokenUseCase.updatePushToken(deviceId, null, previousNode.networkSlug).collect()
        }
    }

    private suspend fun migrateDeviceIdIfNeed() {
        deviceIdMigrationUseCase.migrateDeviceIdIfNeed()
    }

    private fun initializeAccountCacheManager() {
        viewModelScope.launch(Dispatchers.IO) {
            accountCacheManager.initializeAccountCacheMap()
        }
    }

    fun resetBlockPolling() {
        refreshBalanceJob?.cancel()
        blockPollingManager.startJob()
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
                    assetAdditionUseCase.addAssetAdditionToAccountCache(accountPublicKey, assetInformation)
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
                return true
            }
        }
        return false
    }

    fun setupAutoLockManager(lifecycle: Lifecycle) {
        autoLockManager.registerAppLifecycle(lifecycle)
    }
}
