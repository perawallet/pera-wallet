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

package com.algorand.android.modules.firebase.token

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.core.AccountManager
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.deviceregistration.domain.usecase.DeviceRegistrationUseCase
import com.algorand.android.deviceregistration.domain.usecase.FirebasePushTokenUseCase
import com.algorand.android.deviceregistration.domain.usecase.UpdatePushTokenUseCase
import com.algorand.android.models.Account
import com.algorand.android.models.Node
import com.algorand.android.modules.firebase.token.usecase.ApplyNodeChangesUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import com.google.firebase.messaging.FirebaseMessaging
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.launch

@Singleton
class FirebaseTokenManager @Inject constructor(
    private val firebasePushTokenUseCase: FirebasePushTokenUseCase,
    private val deviceRegistrationUseCase: DeviceRegistrationUseCase,
    private val bannersUseCase: BannersUseCase,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val updatePushTokenUseCase: UpdatePushTokenUseCase,
    private val accountManager: AccountManager,
    private val applyNodeChangesUseCase: ApplyNodeChangesUseCase
) : DefaultLifecycleObserver {

    private val _firebasePushTokenStatusFlow = MutableStateFlow<DataResource<Unit>?>(null)
    val firebasePushTokenStatusFlow: SharedFlow<DataResource<Unit>?> get() = _firebasePushTokenStatusFlow

    private val localAccountsCollector: suspend (value: List<Account>) -> Unit = {
        refreshFirebasePushToken(null)
    }

    private val firebasePushTokenCollector: suspend (value: CacheResult<String>?) -> Unit = {
        if (it?.data.isNullOrBlank().not()) {
            registerFirebasePushToken(it?.data.orEmpty())
        }
    }

    private val deviceRegistrationTokenCollector: suspend (value: DataResource<String>) -> Unit = {
        if (it is DataResource.Success) {
            onPushTokenUpdated()
            bannersUseCase.initializeBanner(deviceId = it.data)
        }
    }

    private val updatePushTokenCollector: suspend (value: DataResource<String>) -> Unit = {
        if (it is DataResource.Success) {
            applyNodeChangesUseCase.invoke()
        }
    }

    // TODO: Discuss 'having a listener in Singleton manager class'.
    //  If some other class assigns a listener, others would not work. Solution: flow should be observed instead
    private var listener: Listener? = null

    private var coroutineScope: CoroutineScope? = null
    private var registerDeviceJob: Job? = null
    private var refreshFirebasePushTokenJob: Job? = null

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun refreshFirebasePushToken(previousNode: Node?) {
        refreshFirebasePushTokenJob?.cancel()
        refreshFirebasePushTokenJob = coroutineScope?.launch(Dispatchers.IO) {
            try {
                _firebasePushTokenStatusFlow.emit(DataResource.Loading())
                if (previousNode != null) {
                    deletePreviousNodePushToken(previousNode)
                }
                FirebaseMessaging.getInstance().token.addOnSuccessListener { token ->
                    firebasePushTokenUseCase.setPushToken(token)
                }
            } catch (cancellationException: CancellationException) {
                _firebasePushTokenStatusFlow.emit(DataResource.Error.Api(cancellationException, null))
            }
        }
    }

    private fun initialize() {
        initObservers()
        refreshFirebasePushToken(null)
    }

    private fun initObservers() {
        coroutineScope?.launch(Dispatchers.IO) {
            // Drop 1 added to get any list changes.
            accountManager.accounts.drop(1).collectLatest(localAccountsCollector)
        }
        coroutineScope?.launch(Dispatchers.IO) {
            firebasePushTokenUseCase.getPushTokenCacheFlow().collect(firebasePushTokenCollector)
        }
    }

    private fun registerFirebasePushToken(token: String) {
        registerDeviceJob?.cancel()
        registerDeviceJob = coroutineScope?.launch(Dispatchers.IO) {
            deviceRegistrationUseCase.registerDevice(token).collect(deviceRegistrationTokenCollector)
        }
    }

    private suspend fun deletePreviousNodePushToken(previousNode: Node) {
        val deviceId = deviceIdUseCase.getNodeDeviceId(previousNode) ?: return
        updatePushTokenUseCase.updatePushToken(deviceId, null).collect(updatePushTokenCollector)
    }

    private suspend fun onPushTokenUpdated() {
        _firebasePushTokenStatusFlow.emit(DataResource.Success(Unit))
        listener?.onNodeSwitchCompleted()
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        coroutineScope = CoroutineScope(Job() + Dispatchers.Main)
        initialize()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        coroutineScope?.cancel()
        coroutineScope = null
    }

    fun interface Listener {
        fun onNodeSwitchCompleted()
    }
}
