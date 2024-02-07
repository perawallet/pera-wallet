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
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import androidx.navigation.NavDirections
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NodeDao
import com.algorand.android.deviceregistration.domain.usecase.DeviceIdMigrationUseCase
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.models.Node
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.appopencount.domain.usecase.IncreaseAppOpeningCountUseCase
import com.algorand.android.modules.autolockmanager.ui.usecase.AutoLockManagerUseCase
import com.algorand.android.modules.deeplink.ui.DeeplinkHandler
import com.algorand.android.modules.swap.utils.SwapNavigationDestinationHelper
import com.algorand.android.modules.tracking.main.MainActivityEventTracker
import com.algorand.android.modules.tutorialdialog.domain.usecase.TutorialUseCase
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.network.IndexerInterceptor
import com.algorand.android.network.MobileHeaderInterceptor
import com.algorand.android.repository.NodeRepository
import com.algorand.android.usecase.AccountCacheStatusUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.SendSignedTransactionUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.coremanager.AccountDetailCacheManager
import com.algorand.android.utils.exception.AccountAlreadyOptedIntoAssetException
import com.algorand.android.utils.exception.AssetAlreadyPendingForRemovalException
import com.algorand.android.utils.exceptions.TransactionConfirmationAwaitException
import com.algorand.android.utils.exceptions.TransactionIdNullException
import com.algorand.android.utils.findAllNodes
import com.algorand.android.utils.sendErrorLog
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@Suppress("LongParameterList")
@HiltViewModel
class MainViewModel @Inject constructor(
    private val sharedPref: SharedPreferences,
    private val nodeDao: NodeDao,
    private val indexerInterceptor: IndexerInterceptor,
    private val mobileHeaderInterceptor: MobileHeaderInterceptor,
    private val algodInterceptor: AlgodInterceptor,
    private val accountCacheManager: AccountCacheManager,
    private val deviceIdMigrationUseCase: DeviceIdMigrationUseCase,
    private val mainActivityEventTracker: MainActivityEventTracker,
    private val deepLinkHandler: DeeplinkHandler,
    private val increaseAppOpeningCountUseCase: IncreaseAppOpeningCountUseCase,
    private val tutorialUseCase: TutorialUseCase,
    private val swapNavigationDestinationHelper: SwapNavigationDestinationHelper,
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDetailCacheManager: AccountDetailCacheManager,
    private val nodeRepository: NodeRepository,
    accountCacheStatusUseCase: AccountCacheStatusUseCase,
    private val autoLockManagerUseCase: AutoLockManagerUseCase
) : BaseViewModel() {

    // TODO: Replace this with Flow whenever have time
    val assetOperationResultLiveData = MutableLiveData<Event<Resource<AssetOperationResult>>>()

    // TODO I'll change after checking usage of flow in activity.
    val accountBalanceSyncStatus = accountCacheStatusUseCase.getAccountCacheStatusFlow().asLiveData()

    private val _swapNavigationResultFlow = MutableStateFlow<Event<NavDirections>?>(null)
    val swapNavigationResultFlow: StateFlow<Event<NavDirections>?>
        get() = _swapNavigationResultFlow

    private val _activeNodeFlow = MutableStateFlow<Node?>(null)
    val activeNodeFlow: StateFlow<Node?> get() = _activeNodeFlow
    private var sendTransactionJob: Job? = null
    var refreshBalanceJob: Job? = null

    private var latestFailedAddAssetTransaction: TransactionData.AddAsset? = null

    init {
        initActiveNodeFlow()
        initializeAccountCacheManager()
        initializeNodeInterceptor()
        initializeTutorial()
    }

    fun shouldAppLocked(): Boolean {
        return autoLockManagerUseCase.shouldAppLocked()
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

    private suspend fun migrateDeviceIdIfNeed() {
        deviceIdMigrationUseCase.migrateDeviceIdIfNeed()
    }

    private fun initializeAccountCacheManager() {
        viewModelScope.launch(Dispatchers.IO) {
            accountCacheManager.initializeAccountCacheMap()
        }
    }

    fun onNewNodeActivated() {
        resetBlockPolling()
    }

    /**
     * If we are going to re-enable block polling manager again, we should enable this job here.
     */
    private fun resetBlockPolling() {
        refreshBalanceJob?.cancel()
        accountDetailCacheManager.startJob()
        // blockPollingManager.startJob()
    }

    fun sendAssetOperationSignedTransaction(transaction: SignedTransactionDetail.AssetOperation) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            sendSignedTransactionUseCase.sendSignedTransaction(transaction).collectLatest { dataResource ->
                when (dataResource) {
                    is DataResource.Success -> {
                        latestFailedAddAssetTransaction = null
                        val assetActionResult = getAssetOperationResult(transaction)
                        assetOperationResultLiveData.postValue(Event(Resource.Success(assetActionResult)))
                    }

                    is DataResource.Error.Api -> {
                        assetOperationResultLiveData.postValue(Event(Resource.Error.Api(dataResource.exception)))
                    }

                    is DataResource.Error.Local -> {
                        // TODO add specific strings for exceptions
                        val errorResourceId = when (dataResource.exception) {
                            is AccountAlreadyOptedIntoAssetException -> {
                                R.string.you_are_already
                            }

                            is TransactionConfirmationAwaitException -> {
                                R.string.transaction_confirmation_timed_out
                            }

                            is TransactionIdNullException -> {
                                R.string.an_error_occured
                            }

                            is AssetAlreadyPendingForRemovalException -> {
                                R.string.this_asset_is
                            }

                            else -> {
                                R.string.an_error_occured
                            }
                        }
                        val assetName = transaction.assetInformation.fullName.toString()
                        assetOperationResultLiveData.postValue(
                            Event(
                                Resource.Error.GlobalWarning(
                                    titleRes = R.string.error,
                                    annotatedString = AnnotatedString(
                                        stringResId = errorResourceId,
                                        replacementList = listOf("asset_name" to assetName)
                                    )
                                )
                            )
                        )
                    }

                    else -> {
                        sendErrorLog("Unhandled else case in MainViewModel.sendSignedTransaction")
                    }
                }
            }
        }
    }

    fun getLatestAddAssetTransaction(): TransactionData.AddAsset? {
        return latestFailedAddAssetTransaction
    }

    fun setLatestAddAssetTransaction(transactionData: TransactionData.AddAsset) {
        latestFailedAddAssetTransaction = transactionData
    }

    fun handleDeepLink(uri: String) {
        deepLinkHandler.handleDeepLink(uri)
    }

    fun setDeepLinkHandlerListener(listener: DeeplinkHandler.Listener) {
        deepLinkHandler.setListener(listener)
    }

    fun logBottomNavAccountsTapEvent() {
        viewModelScope.launch {
            mainActivityEventTracker.logAccountsTapEvent()
        }
    }

    fun logBottomNavigationBuyAlgoEvent() {
        viewModelScope.launch {
            mainActivityEventTracker.logBottomNavigationAlgoBuyTapEvent()
        }
    }

    fun increseAppOpeningCount() {
        viewModelScope.launch {
            increaseAppOpeningCountUseCase.increaseAppOpeningCount()
        }
    }

    fun onSwapActionButtonClick() {
        viewModelScope.launch {
            mainActivityEventTracker.logQuickActionSwapButtonClickEvent()
            var swapNavDirection: NavDirections? = null
            swapNavigationDestinationHelper.getSwapNavigationDestination(
                onNavToIntroduction = {
                    swapNavDirection = HomeNavigationDirections.actionGlobalSwapIntroductionNavigation()
                },
                onNavToAccountSelection = {
                    swapNavDirection = HomeNavigationDirections.actionGlobalSwapAccountSelectionNavigation()
                },
                onNavToSwap = { accountAddress ->
                    swapNavDirection = HomeNavigationDirections.actionGlobalSwapNavigation(accountAddress)
                }
            )
            swapNavDirection?.let { direction ->
                _swapNavigationResultFlow.emit(Event(direction))
            }
        }
    }

    private fun initializeTutorial() {
        viewModelScope.launch {
            tutorialUseCase.initializeTutorial()
        }
    }

    private fun getAssetOperationResult(transaction: SignedTransactionDetail.AssetOperation): AssetOperationResult {
        val assetName = transaction.assetInformation.fullName ?: transaction.assetInformation.shortName
        return when (transaction) {
            is SignedTransactionDetail.AssetOperation.AssetAddition -> {
                AssetOperationResult.AssetAdditionOperationResult(
                    resultTitleResId = R.string.asset_successfully_opted_in,
                    assetName = AssetName.create(assetName),
                    assetId = transaction.assetInformation.assetId
                )
            }

            is SignedTransactionDetail.AssetOperation.AssetRemoval -> {
                AssetOperationResult.AssetRemovalOperationResult(
                    resultTitleResId = R.string.asset_successfully_opted_out_from_your,
                    assetName = AssetName.create(assetName),
                    assetId = transaction.assetInformation.assetId
                )
            }
        }
    }

    private fun initActiveNodeFlow() {
        viewModelScope.launch(Dispatchers.IO) {
            nodeRepository.getActiveNodeAsFlow().collectLatest {
                _activeNodeFlow.value = it
            }
        }
    }
}
